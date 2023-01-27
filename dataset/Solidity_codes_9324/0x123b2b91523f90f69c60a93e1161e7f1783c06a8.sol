
pragma solidity =0.5.16;
pragma experimental ABIEncoderV2;




library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {

        if (a == 0)
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256)
    {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IGame {

    function block2timestamp(uint256 blockNumber) external view returns (uint256);

    function serial2player(uint256 serial) external view returns (address payable);


    function getStatus() external view
        returns (
            uint256 timer,
            uint256 roundCounter,
            uint256 playerCounter,
            uint256 messageCounter,
            uint256 cookieCounter,

            uint256 cookieFund,
            uint256 winnerFund,

            uint256 surpriseIssued,
            uint256 bonusIssued,
            uint256 cookieIssued,
            uint256 shareholderIssued
        );


    function getPlayer(address account) external view
        returns (
            uint256 serial,
            bytes memory name,
            bytes memory adviserName,
            address payable adviser,
            uint256 messageCounter,
            uint256 cookieCounter,
            uint256 followerCounter,
            uint256 followerMessageCounter,
            uint256 followerCookieCounter,
            uint256 bonusWeis,
            uint256 surpriseWeis
        );


    function getPlayerPrime(address account) external view
        returns (
            bytes memory playerName,
            uint256 pinnedMessageSerial,
            uint8 topPlayerPosition,
            uint8 shareholderPosition,
            uint256 shareholderStakingWeis,
            uint256 shareholderProfitWeis,
            uint256 shareholderFirstBlockNumber
        );


    function getPlayerDisplay(address account) external view
        returns (
            uint256 messageCounter,
            uint256 pinnedMessageSerial,

            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        );


    function getPlayerMessage(address account, uint256 serial) external view
        returns (
            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        );


    function getPlayerCookie(address account, uint256 serial) external view
        returns (
            uint256 cookieSerial,

            address payable player,
            address payable adviser,
            bytes memory playerName,
            bytes memory adviserName,
            uint256 playerWeis,
            uint256 adviserWeis,

            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        );


    function getPlayerFollowerCookie(address account, uint256 serial) external view
        returns (
            uint256 cookieSerial,

            address payable player,
            address payable adviser,
            bytes memory playerName,
            bytes memory adviserName,
            uint256 playerWeis,
            uint256 adviserWeis,

            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        );


    function getPlayerFollower(address account, uint256 serial) external view
        returns (address payable);

}


library GameLib {

    struct Message {
        uint256 serial;
        address account;
        bytes name;
        bytes text;
        uint256 blockNumber;
    }

    struct Cookie {
        uint256 serial;

        address payable player;
        address payable adviser;
        bytes playerName;
        bytes adviserName;
        uint256 playerWeis;
        uint256 adviserWeis;

        uint256 messageSerial;
        bytes text;
        uint256 blockNumber;
    }

    struct Round {
        uint256 openedBlock;
        uint256 closingBlock;
        uint256 closedTimestamp;
        uint256 openingWinnerFund;
        uint256 closingWinnerFund;
        address payable opener;
        uint256 openerBonus;
    }
}


library PlayerLib {

    struct Player {
        uint256 serial;

        bytes name;
        bytes adviserName;
        address payable adviser;
        uint256 messageCounter;
        uint256 cookieCounter;
        uint256 followerCounter;
        uint256 followerMessageCounter;
        uint256 followerCookieCounter;
        uint256 bonusWeis;
        uint256 surpriseWeis;
    }
}

contract ReaderB {

    using SafeMath for uint256;
    using PlayerLib for PlayerLib.Player;

    IGame private _game;

    uint8 constant SM_PAGE = 10;
    uint8 constant LG_PAGE = 20;
    uint8 constant SHAREHOLDER_MAX_POSITION = 6;
    uint8 constant TOP_PLAYER_MAX_POSITION = 20;
    uint8 constant WINNERS_PER_ROUND = 10;


    constructor ()
        public
    {
        _game = IGame(0x1234567B172f040f45D7e924C0a7d088016191A6);
    }

    function () external payable {
        revert("Cannot deposit");
    }

    function game()
        public
        view
        returns (address)
    {

        return address(_game);
    }

    function player(address account)
        public
        view
        returns (
            uint256 serial,
            bytes memory name,
            bytes memory adviserName,
            address payable adviser,
            uint256 messageCounter,
            uint256 cookieCounter,
            uint256 followerCounter,
            uint256 followerMessageCounter,
            uint256 followerCookieCounter,
            uint256 bonusWeis,
            uint256 surpriseWeis,
            uint256 firstMessageTimestamp
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        serial = thePlayer.serial;
        name = thePlayer.name;
        adviserName = thePlayer.adviserName;
        adviser = thePlayer.adviser;
        messageCounter = thePlayer.messageCounter;
        cookieCounter = thePlayer.cookieCounter;
        followerCounter = thePlayer.followerCounter;
        followerMessageCounter = thePlayer.followerMessageCounter;
        followerCookieCounter = thePlayer.followerCookieCounter;
        bonusWeis = thePlayer.bonusWeis;
        surpriseWeis = thePlayer.surpriseWeis;

        (, firstMessageTimestamp) = _playerFirstMessageBT(account);
    }

    function playerAt(uint256 playerSerial)
        public
        view
        returns (
            bytes memory name,
            bytes memory adviserName,
            address payable account,
            address payable adviser,
            uint256 messageCounter,
            uint256 cookieCounter,
            uint256 followerCounter,
            uint256 followerMessageCounter,
            uint256 followerCookieCounter,
            uint256 bonusWeis,
            uint256 surpriseWeis,
            uint256 firstMessageTimestamp
        )
    {

        if (playerSerial > 0)
        {
            account =_game.serial2player(playerSerial);

            PlayerLib.Player memory thePlayer = _player(account);

            adviser = thePlayer.adviser;

            name = thePlayer.name;
            adviserName = thePlayer.adviserName;
            messageCounter = thePlayer.messageCounter;
            cookieCounter = thePlayer.cookieCounter;
            followerCounter = thePlayer.followerCounter;
            followerMessageCounter = thePlayer.followerMessageCounter;
            followerCookieCounter = thePlayer.followerCookieCounter;
            bonusWeis = thePlayer.bonusWeis;
            surpriseWeis = thePlayer.surpriseWeis;

            (, firstMessageTimestamp) = _playerFirstMessageBT(account);
        }
    }

    function playerPrime(address account)
        public
        view
        returns (
            uint256 pinnedMessageSerial,

            uint256 firstMessageBlockNumber,
            uint256 firstMessageTimestamp,

            uint8 topPlayerPosition,

            uint8 shareholderPosition,
            uint256 shareholderStakingWeis,
            uint256 shareholderProfitWeis,
            uint256 shareholderFirstBlockNumber,
            uint256 shareholderFirstTimestamp
        )
    {

        (
            firstMessageBlockNumber,
            firstMessageTimestamp
        )
        = _playerFirstMessageBT(account);

        (
            , // bytes memory playerName,
            pinnedMessageSerial,

            topPlayerPosition,

            shareholderPosition,
            shareholderStakingWeis,
            shareholderProfitWeis,
            shareholderFirstBlockNumber
        )
        = _game.getPlayerPrime(account);

        shareholderFirstTimestamp = _game.block2timestamp(shareholderFirstBlockNumber);
    }

    function playerMessages(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,

            uint256[SM_PAGE] memory messageSerials,
            bytes[SM_PAGE] memory texts,
            uint256[SM_PAGE] memory blockNumbers,
            uint256[SM_PAGE] memory timestamps
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        if (thePlayer.messageCounter > 0)
        {
            if (till == 0)
            {
                till = thePlayer.messageCounter;
            }

            if (till <= thePlayer.messageCounter)
            {
                for (uint256 i = 0; i < SM_PAGE; i++)
                {
                    uint256 serial = till.sub(i);
                    if (serial < 1)
                    {
                        break;
                    }

                    GameLib.Message memory theMessage = _playerMessage(account, serial);

                    serials[i] = serial;

                    messageSerials[i] = theMessage.serial;
                    texts[i] = theMessage.text;
                    blockNumbers[i] = theMessage.blockNumber;
                    timestamps[i] = _game.block2timestamp(theMessage.blockNumber);
                }
            }
        }
    }

    function playerCookies(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory advisers,
            bytes[SM_PAGE] memory adviserNames,
            uint256[SM_PAGE] memory playerWeis,
            uint256[SM_PAGE] memory adviserWeis,

            uint256[SM_PAGE] memory messageSerials,
            bytes[SM_PAGE] memory texts,
            uint256[SM_PAGE] memory blockNumbers,
            uint256[SM_PAGE] memory timestamps
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        if (thePlayer.cookieCounter > 0)
        {
            if (till == 0)
            {
                till = thePlayer.cookieCounter;
            }

            if (till <= thePlayer.cookieCounter)
            {
                for (uint256 i = 0; i < SM_PAGE; i++)
                {
                    uint256 serial = till.sub(i);
                    if (serial < 1)
                    {
                        break;
                    }

                    GameLib.Cookie memory cookie = _playerCookie(account, serial);

                    serials[i] = cookie.serial;
                    advisers[i] = cookie.adviser;
                    adviserNames[i] = cookie.adviserName;
                    playerWeis[i] = cookie.playerWeis;
                    adviserWeis[i] = cookie.adviserWeis;

                    messageSerials[i] = cookie.messageSerial;
                    texts[i] = cookie.text;
                    blockNumbers[i] = cookie.blockNumber;
                    timestamps[i] = _game.block2timestamp(cookie.blockNumber);
                }
            }
        }
    }

    function playerFollowerCookies(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory players,
            bytes[SM_PAGE] memory playerNames,
            uint256[SM_PAGE] memory playerWeis,
            uint256[SM_PAGE] memory adviserWeis,

            uint256[SM_PAGE] memory messageSerials,
            bytes[SM_PAGE] memory texts,
            uint256[SM_PAGE] memory blockNumbers,
            uint256[SM_PAGE] memory timestamps
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        if (thePlayer.followerCookieCounter > 0)
        {
            if (till == 0)
            {
                till = thePlayer.followerCookieCounter;
            }

            if (till <= thePlayer.followerCookieCounter)
            {
                for (uint256 i = 0; i < SM_PAGE; i++)
                {
                    uint256 serial = till.sub(i);
                    if (serial < 1)
                    {
                        break;
                    }

                    GameLib.Cookie memory cookie = _playerFollowerCookie(account, serial);

                    serials[i] = cookie.serial;
                    players[i] = cookie.player;
                    playerNames[i] = cookie.playerName;
                    playerWeis[i] = cookie.playerWeis;
                    adviserWeis[i] = cookie.adviserWeis;

                    messageSerials[i] = cookie.messageSerial;
                    texts[i] = cookie.text;
                    blockNumbers[i] = cookie.blockNumber;
                    timestamps[i] = _game.block2timestamp(cookie.blockNumber);
                }
            }
        }
    }

    function playerFollowersA(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory playerSerials,
            bytes[SM_PAGE] memory names,
            bytes[SM_PAGE] memory adviserNames,
            address[SM_PAGE] memory advisers,
            uint256[SM_PAGE] memory bonusWeis,
            uint256[SM_PAGE] memory surpriseWeis,

            uint256[SM_PAGE] memory messageSerials,
            uint256[SM_PAGE] memory messageBlockNumbers,
            uint256[SM_PAGE] memory messageTimestamps,
            bytes[SM_PAGE] memory messageTexts
        )
    {

        (serials, accounts) = _playerFollowerAccounts(account, till);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                playerSerials[i] = thePlayer.serial;
                names[i] = thePlayer.name;

                adviserNames[i] = thePlayer.adviserName;
                advisers[i] = thePlayer.adviser;

                bonusWeis[i] = thePlayer.bonusWeis;
                surpriseWeis[i] = thePlayer.surpriseWeis;

                (
                    , // uint256 messageCounter,
                    , // uint256 pinnedMessageSerial,
                    messageSerials[i],
                    messageTexts[i],
                    messageBlockNumbers[i]
                )
                = _game.getPlayerDisplay(accounts[i]);

                messageTimestamps[i] = _game.block2timestamp(messageBlockNumbers[i]);
            }
        }
    }
    function playerFollowersB(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory messageCounters,
            uint256[SM_PAGE] memory cookieCounters,
            uint256[SM_PAGE] memory followerCounters,
            uint256[SM_PAGE] memory followerMessageCounters,
            uint256[SM_PAGE] memory followerCookieCounters,

            uint256[SM_PAGE] memory firstMessageBlockNumbers,
            uint256[SM_PAGE] memory firstMessageTimestamps
        )
    {

        (serials, accounts) = _playerFollowerAccounts(account, till);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                messageCounters[i] = thePlayer.messageCounter;
                cookieCounters[i] = thePlayer.cookieCounter;

                followerCounters[i] = thePlayer.followerCounter;
                followerMessageCounters[i] = thePlayer.followerMessageCounter;
                followerCookieCounters[i] = thePlayer.followerCookieCounter;

                (
                    firstMessageBlockNumbers[i],
                    firstMessageTimestamps[i]
                )
                = _playerFirstMessageBT(accounts[i]);
            }
        }
    }
    function playerFollowersC(address account, uint256 till)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory pinnedMessageSerials,

            uint8[SM_PAGE] memory topPlayerPositions,
            uint8[SM_PAGE] memory shareholderPositions,
            uint256[SM_PAGE] memory shareholderStakingWeis,
            uint256[SM_PAGE] memory shareholderProfitWeis,
            uint256[SM_PAGE] memory shareholderFirstBlockNumbers,
            uint256[SM_PAGE] memory shareholderFirstTimestamps
        )
    {

        (serials, accounts) = _playerFollowerAccounts(account, till);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                (
                    pinnedMessageSerials[i],
                    , // uint256 firstMessageBlockNumber,
                    , // uint256 firstMessageTimestamp,
                    topPlayerPositions[i],
                    shareholderPositions[i],
                    shareholderStakingWeis[i],
                    shareholderProfitWeis[i],
                    shareholderFirstBlockNumbers[i],
                    shareholderFirstTimestamps[i]
                )
                = playerPrime(accounts[i]);
            }
        }
    }





    function playerAdvisersA(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory playerSerials,
            bytes[SM_PAGE] memory names,
            bytes[SM_PAGE] memory adviserNames,
            address[SM_PAGE] memory advisers,
            uint256[SM_PAGE] memory bonusWeis,
            uint256[SM_PAGE] memory surpriseWeis,

            uint256[SM_PAGE] memory messageSerials,
            uint256[SM_PAGE] memory messageBlockNumbers,
            uint256[SM_PAGE] memory messageTimestamps,
            bytes[SM_PAGE] memory messageTexts
        )
    {

        (serials, accounts) = _playerAdviserAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                playerSerials[i] = thePlayer.serial;
                names[i] = thePlayer.name;

                adviserNames[i] = thePlayer.adviserName;
                advisers[i] = thePlayer.adviser;

                bonusWeis[i] = thePlayer.bonusWeis;
                surpriseWeis[i] = thePlayer.surpriseWeis;

                (
                    , // uint256 messageCounter,
                    , // uint256 pinnedMessageSerial,
                    messageSerials[i],
                    messageTexts[i],
                    messageBlockNumbers[i]
                )
                = _game.getPlayerDisplay(accounts[i]);

                messageTimestamps[i] = _game.block2timestamp(messageBlockNumbers[i]);
            }
        }
    }
    function playerAdvisersB(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory messageCounters,
            uint256[SM_PAGE] memory cookieCounters,
            uint256[SM_PAGE] memory followerCounters,
            uint256[SM_PAGE] memory followerMessageCounters,
            uint256[SM_PAGE] memory followerCookieCounters,

            uint256[SM_PAGE] memory firstMessageBlockNumbers,
            uint256[SM_PAGE] memory firstMessageTimestamps
        )
    {

        (serials, accounts) = _playerAdviserAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                messageCounters[i] = thePlayer.messageCounter;
                cookieCounters[i] = thePlayer.cookieCounter;

                followerCounters[i] = thePlayer.followerCounter;
                followerMessageCounters[i] = thePlayer.followerMessageCounter;
                followerCookieCounters[i] = thePlayer.followerCookieCounter;

                (
                    firstMessageBlockNumbers[i],
                    firstMessageTimestamps[i]
                )
                = _playerFirstMessageBT(accounts[i]);
            }
        }
    }
    function playerAdvisersC(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory pinnedMessageSerials,

            uint8[SM_PAGE] memory topPlayerPositions,
            uint8[SM_PAGE] memory shareholderPositions,
            uint256[SM_PAGE] memory shareholderStakingWeis,
            uint256[SM_PAGE] memory shareholderProfitWeis,
            uint256[SM_PAGE] memory shareholderFirstBlockNumbers,
            uint256[SM_PAGE] memory shareholderFirstTimestamps
        )
    {

        (serials, accounts) = _playerAdviserAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                (
                    pinnedMessageSerials[i],
                    , // uint256 firstMessageBlockNumber,
                    , // uint256 firstMessageTimestamp,
                    topPlayerPositions[i],
                    shareholderPositions[i],
                    shareholderStakingWeis[i],
                    shareholderProfitWeis[i],
                    shareholderFirstBlockNumbers[i],
                    shareholderFirstTimestamps[i]
                )
                = playerPrime(accounts[i]);
            }
        }
    }


    function playerPreviousA(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory playerSerials,
            bytes[SM_PAGE] memory names,
            bytes[SM_PAGE] memory adviserNames,
            address[SM_PAGE] memory advisers,
            uint256[SM_PAGE] memory bonusWeis,
            uint256[SM_PAGE] memory surpriseWeis,

            uint256[SM_PAGE] memory messageSerials,
            uint256[SM_PAGE] memory messageBlockNumbers,
            uint256[SM_PAGE] memory messageTimestamps,
            bytes[SM_PAGE] memory messageTexts
        )
    {

        (serials, accounts) = _playerPreviousAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                playerSerials[i] = thePlayer.serial;
                names[i] = thePlayer.name;

                adviserNames[i] = thePlayer.adviserName;
                advisers[i] = thePlayer.adviser;

                bonusWeis[i] = thePlayer.bonusWeis;
                surpriseWeis[i] = thePlayer.surpriseWeis;

                (
                    , // uint256 messageCounter,
                    , // uint256 pinnedMessageSerial,
                    messageSerials[i],
                    messageTexts[i],
                    messageBlockNumbers[i]
                )
                = _game.getPlayerDisplay(accounts[i]);

                messageTimestamps[i] = _game.block2timestamp(messageBlockNumbers[i]);
            }
        }
    }
    function playerPreviousB(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory messageCounters,
            uint256[SM_PAGE] memory cookieCounters,
            uint256[SM_PAGE] memory followerCounters,
            uint256[SM_PAGE] memory followerMessageCounters,
            uint256[SM_PAGE] memory followerCookieCounters,

            uint256[SM_PAGE] memory firstMessageBlockNumbers,
            uint256[SM_PAGE] memory firstMessageTimestamps
        )
    {

        (serials, accounts) = _playerPreviousAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                messageCounters[i] = thePlayer.messageCounter;
                cookieCounters[i] = thePlayer.cookieCounter;

                followerCounters[i] = thePlayer.followerCounter;
                followerMessageCounters[i] = thePlayer.followerMessageCounter;
                followerCookieCounters[i] = thePlayer.followerCookieCounter;

                (
                    firstMessageBlockNumbers[i],
                    firstMessageTimestamps[i]
                )
                = _playerFirstMessageBT(accounts[i]);
            }
        }
    }
    function playerPreviousC(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory pinnedMessageSerials,

            uint8[SM_PAGE] memory topPlayerPositions,
            uint8[SM_PAGE] memory shareholderPositions,
            uint256[SM_PAGE] memory shareholderStakingWeis,
            uint256[SM_PAGE] memory shareholderProfitWeis,
            uint256[SM_PAGE] memory shareholderFirstBlockNumbers,
            uint256[SM_PAGE] memory shareholderFirstTimestamps
        )
    {

        (serials, accounts) = _playerPreviousAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                (
                    pinnedMessageSerials[i],
                    , // uint256 firstMessageBlockNumber,
                    , // uint256 firstMessageTimestamp,
                    topPlayerPositions[i],
                    shareholderPositions[i],
                    shareholderStakingWeis[i],
                    shareholderProfitWeis[i],
                    shareholderFirstBlockNumbers[i],
                    shareholderFirstTimestamps[i]
                )
                = playerPrime(accounts[i]);
            }
        }
    }


    function playerNextA(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory playerSerials,
            bytes[SM_PAGE] memory names,
            bytes[SM_PAGE] memory adviserNames,
            address[SM_PAGE] memory advisers,
            uint256[SM_PAGE] memory bonusWeis,
            uint256[SM_PAGE] memory surpriseWeis,

            uint256[SM_PAGE] memory messageSerials,
            uint256[SM_PAGE] memory messageBlockNumbers,
            uint256[SM_PAGE] memory messageTimestamps,
            bytes[SM_PAGE] memory messageTexts
        )
    {

        (serials, accounts) = _playerNextAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                playerSerials[i] = thePlayer.serial;
                names[i] = thePlayer.name;

                adviserNames[i] = thePlayer.adviserName;
                advisers[i] = thePlayer.adviser;

                bonusWeis[i] = thePlayer.bonusWeis;
                surpriseWeis[i] = thePlayer.surpriseWeis;

                (
                    , // uint256 messageCounter,
                    , // uint256 pinnedMessageSerial,
                    messageSerials[i],
                    messageTexts[i],
                    messageBlockNumbers[i]
                )
                = _game.getPlayerDisplay(accounts[i]);

                messageTimestamps[i] = _game.block2timestamp(messageBlockNumbers[i]);
            }
        }
    }
    function playerNextB(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory messageCounters,
            uint256[SM_PAGE] memory cookieCounters,
            uint256[SM_PAGE] memory followerCounters,
            uint256[SM_PAGE] memory followerMessageCounters,
            uint256[SM_PAGE] memory followerCookieCounters,

            uint256[SM_PAGE] memory firstMessageBlockNumbers,
            uint256[SM_PAGE] memory firstMessageTimestamps
        )
    {

        (serials, accounts) = _playerNextAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                PlayerLib.Player memory thePlayer = _player(accounts[i]);

                messageCounters[i] = thePlayer.messageCounter;
                cookieCounters[i] = thePlayer.cookieCounter;

                followerCounters[i] = thePlayer.followerCounter;
                followerMessageCounters[i] = thePlayer.followerMessageCounter;
                followerCookieCounters[i] = thePlayer.followerCookieCounter;

                (
                    firstMessageBlockNumbers[i],
                    firstMessageTimestamps[i]
                )
                = _playerFirstMessageBT(accounts[i]);
            }
        }
    }
    function playerNextC(address account)
        public
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts,

            uint256[SM_PAGE] memory pinnedMessageSerials,

            uint8[SM_PAGE] memory topPlayerPositions,
            uint8[SM_PAGE] memory shareholderPositions,
            uint256[SM_PAGE] memory shareholderStakingWeis,
            uint256[SM_PAGE] memory shareholderProfitWeis,
            uint256[SM_PAGE] memory shareholderFirstBlockNumbers,
            uint256[SM_PAGE] memory shareholderFirstTimestamps
        )
    {

        (serials, accounts) = _playerNextAccounts(account);

        for (uint256 i = 0; i < accounts.length; i++)
        {
            if (accounts[i] != address(0))
            {
                (
                    pinnedMessageSerials[i],
                    , // uint256 firstMessageBlockNumber,
                    , // uint256 firstMessageTimestamp,
                    topPlayerPositions[i],
                    shareholderPositions[i],
                    shareholderStakingWeis[i],
                    shareholderProfitWeis[i],
                    shareholderFirstBlockNumbers[i],
                    shareholderFirstTimestamps[i]
                )
                = playerPrime(accounts[i]);
            }
        }
    }



    function _playerFirstMessageBT(address account)
        private
        view
        returns (
            uint256 blockNumber,
            uint256 timestamp
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        if (thePlayer.messageCounter > 0)
        {
            GameLib.Message memory theMessage = _playerMessage(account, 1);

            blockNumber = theMessage.blockNumber;
            timestamp = _game.block2timestamp(blockNumber);
        }
    }

    function _playerFollowerAccounts(address account, uint256 till)
        private
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts
        )
    {

        PlayerLib.Player memory thePlayer = _player(account);

        if (thePlayer.followerCounter > 0)
        {
            if (till == 0)
            {
                till = thePlayer.followerCounter;
            }

            if (till <= thePlayer.followerCounter)
            {
                for (uint256 i = 0; i < SM_PAGE; i++)
                {
                    uint256 serial = till.sub(i);
                    if (serial < 1)
                    {
                        break;
                    }

                    address payable follower = _game.getPlayerFollower(account, serial);

                    serials[i] = serial;
                    accounts[i] = follower;
                }
            }
        }
    }

    function _playerAdviserAccounts(address account)
        private
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts
        )
    {

        if (account != address(0))
        {
            for (uint8 i = 0; i < SM_PAGE; i++)
            {
                address adviser = _player(account).adviser;

                if (adviser == account || adviser == address(0))
                {
                    break;
                }

                serials[i] = i + 1;
                accounts[i] = adviser;
                account = adviser;
            }
        }
    }

    function _playerPreviousAccounts(address account)
        private
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts
        )
    {

        uint256 previousPlayerSerial;

        uint8 i = 0;

        if (account == address(0))
        {
            (
                , // uint256 timer,
                , // uint256 roundCounter,
                previousPlayerSerial,
                , // uint256 messageCounter,
                , // uint256 cookieCounter,

                , // uint256 cookieFund,
                , // uint256 winnerFund,

                , // uint256 surpriseIssued,
                , // uint256 bonusIssued,
                , // uint256 cookieIssued,
            )
            = _game.getStatus();

            serials[i] = 1;
            accounts[i] = _game.serial2player(previousPlayerSerial);

            i++;
        } else {
            previousPlayerSerial = _player(account).serial.sub(1);
        }

        uint256 playerSerial;

        for (i; i < SM_PAGE; i++)
        {
            playerSerial = previousPlayerSerial.sub(i);

            if (playerSerial < 1)
            {
                break;
            }

            serials[i] = i + 1;
            accounts[i] = _game.serial2player(playerSerial);
        }
    }

    function _playerNextAccounts(address account)
        private
        view
        returns (
            uint256[SM_PAGE] memory serials,
            address[SM_PAGE] memory accounts
        )
    {

        (
            , // uint256 timer,
            , // uint256 roundCounter,
            uint256 playerCounter,
            , // uint256 messageCounter,
            , // uint256 cookieCounter,

            , // uint256 cookieFund,
            , // uint256 winnerFund,

            , // uint256 surpriseIssued,
            , // uint256 bonusIssued,
            , // uint256 cookieIssued,
        )
        = _game.getStatus();

        uint256 nextPlayerSerial = _player(account).serial.add(1);
        uint256 playerSerial;

        for (uint8 i = 0; i < SM_PAGE; i++)
        {
            playerSerial = nextPlayerSerial.add(i);

            if (playerSerial > playerCounter)
            {
                break;
            }

            serials[i] = i + 1;
            accounts[i] = _game.serial2player(playerSerial);
        }
    }

    function _player(address account)
        private
        view
        returns (PlayerLib.Player memory)
    {

        (
            uint256 serial,
            bytes memory name,
            bytes memory adviserName,
            address payable adviser,
            uint256 messageCounter,
            uint256 cookieCounter,
            uint256 followerCounter,
            uint256 followerMessageCounter,
            uint256 followerCookieCounter,
            uint256 bonusWeis,
            uint256 surpriseWeis
        )
        = _game.getPlayer(account);

        return PlayerLib.Player(
            serial,
            name,
            adviserName,
            adviser,
            messageCounter,
            cookieCounter,
            followerCounter,
            followerMessageCounter,
            followerCookieCounter,
            bonusWeis,
            surpriseWeis
        );
    }

    function _playerMessage(address account, uint256 serial)
        private
        view
        returns (GameLib.Message memory)
    {

        (
            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        )
        = _game.getPlayerMessage(account, serial);

        PlayerLib.Player memory thePlayer = _player(account);

        return GameLib.Message(messageSerial, account, thePlayer.name, text, blockNumber);
    }

    function _playerCookie(address account, uint256 serial)
        private
        view
        returns (GameLib.Cookie memory)
    {

        (
            uint256 cookieSerial,

            address payable playerAccount,
            address payable adviserAccount,
            bytes memory playerName,
            bytes memory adviserName,
            uint256 playerWeis,
            uint256 adviserWeis,

            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        )
        = _game.getPlayerCookie(account, serial);

        return GameLib.Cookie(cookieSerial, playerAccount, adviserAccount, playerName, adviserName, playerWeis, adviserWeis, messageSerial, text, blockNumber);
    }

    function _playerFollowerCookie(address account, uint256 serial)
        private
        view
        returns (GameLib.Cookie memory)
    {

        (
            uint256 cookieSerial,

            address payable playerAccount,
            address payable adviserAccount,
            bytes memory playerName,
            bytes memory adviserName,
            uint256 playerWeis,
            uint256 adviserWeis,

            uint256 messageSerial,
            bytes memory text,
            uint256 blockNumber
        )
        = _game.getPlayerFollowerCookie(account, serial);

        return GameLib.Cookie(cookieSerial, playerAccount, adviserAccount, playerName, adviserName, playerWeis, adviserWeis, messageSerial, text, blockNumber);
    }
}