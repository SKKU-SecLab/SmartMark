






abstract contract Ownable {
    address _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
    }
}


pragma solidity ^0.8.7;

abstract contract HasRandom {
    uint256 _randomNonce = 1;

    function _random() internal returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        _randomNonce++,
                        block.timestamp
                    )
                )
            );
    }
}


pragma solidity ^0.8.7;

interface IERC721 {

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}






struct State {
    uint256 a;
    uint256 b;
    uint256 c;
    uint256 number;
    uint256 rewardErc20;
    uint256 rewardNftId;
}

contract StiltMachine is Ownable, HasRandom {

    IERC20 public erc20;
    IERC721 public nft;
    address public caasbank;
    mapping(address => State) public states;
    uint256 public jackpotPercent = 50;
    bool isStarted;

    event OnWin(address indexed account, uint256 id);

    constructor(address erc20Address, address nftAddress) {
        erc20 = IERC20(erc20Address);
        nft = IERC721(nftAddress);
    }

    function setErc20(address erc20Address) external onlyOwner {

        erc20 = IERC20(erc20Address);
    }

    function setNft(address nftAddress) external onlyOwner {

        nft = IERC721(nftAddress);
    }

    function setIsStarted(bool newIsStarted) external onlyOwner {

        isStarted = newIsStarted;
    }

    function setCaasbank(address caasbankAddress) external onlyOwner {

        caasbank = caasbankAddress;
    }

    function setJackpotPercent(uint256 newJakpotPercent) external onlyOwner {

        require(newJakpotPercent > 0 && newJakpotPercent <= 100);
        jackpotPercent = newJakpotPercent;
    }

    function getJackPot() public view returns (uint256) {

        return (erc20.balanceOf(address(this)) * jackpotPercent) / 100;
    }

    function getRewardPool() public view returns (uint256) {

        return erc20.balanceOf(address(this));
    }

    function withdrawErc20() external onlyOwner {

        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0);
        if (balance > 0) erc20.transfer(msg.sender, balance);
    }

    function withdrawNft() external onlyOwner {

        uint256 balance = nft.balanceOf(address(this));
        require(balance > 0);
        while (balance > 0) {
            nft.safeTransferFrom(
                address(this),
                msg.sender,
                nft.tokenOfOwnerByIndex(address(this), 0)
            );
            --balance;
        }
    }

    function Play(uint256 bid) public {

        require(isStarted, "is not started");
        State storage state = states[msg.sender];
        state.a = _random() % 6;
        state.b = _random() % 6;
        state.c = _random() % 6;
        ++state.number;
        state.rewardErc20 = 0;
        state.rewardNftId = 0;

        bool win;
        if (state.a == 5 && state.b == 5 && state.c == 5) {
            emit OnWin(msg.sender, 5);
            win = true;
            state.rewardErc20 = getJackPot();
            if (address(nft) != address(0)) {
                uint256 nftBalance = nft.balanceOf(address(this));
                if (nftBalance > 0) {
                    state.rewardNftId = nft.tokenOfOwnerByIndex(
                        address(this),
                        0
                    );
                    nft.safeTransferFrom(
                        address(this),
                        msg.sender,
                        state.rewardNftId
                    );
                }
            }
        }
        else if (state.a == 4 && state.b == 4 && state.c == 4) {
            emit OnWin(msg.sender, 4);
            win = true;
            state.rewardErc20 = bid;
            return;
        }
        else if (state.a == 3 && state.b == 3 && state.c == 3) {
            emit OnWin(msg.sender, 3);
            win = true;
            state.rewardErc20 = bid * 3;
        }
        else if (state.a == 2 && state.b == 2 && state.c == 2) {
            emit OnWin(msg.sender, 2);
            win = true;
            state.rewardErc20 = bid * 5;
        }
        else if (state.a == 1 && state.b == 1 && state.c == 1) {
            emit OnWin(msg.sender, 1);
            win = true;
            state.rewardErc20 = bid * 10;
        }
        else if (state.a == 0 && state.b == 0 && state.c == 0) {
            emit OnWin(msg.sender, 0);
            win = true;
            state.rewardErc20 = bid * 100;
        }

        uint256 balance = erc20.balanceOf(address(this));
        if (balance < state.rewardErc20) state.rewardErc20 = balance;

        if (win) {
            if (state.rewardErc20 > 0)
                erc20.transfer(msg.sender, state.rewardErc20);
            return;
        }

        if (caasbank == address(0)) {
            erc20.transferFrom(msg.sender, address(this), bid);
        } else {
            erc20.transferFrom(msg.sender, address(this), bid / 2);
            bid -= bid / 2;
            erc20.transferFrom(msg.sender, caasbank, bid);
        }
    }
}