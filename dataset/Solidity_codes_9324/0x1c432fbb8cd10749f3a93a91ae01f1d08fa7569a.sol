pragma solidity =0.8.10;

struct Notice {
    address subject;
    bytes data;
}

contract NoticeBoard {

    event NewNotice(address sender, Notice notice);

    function createNotices(Notice[] calldata notices_) external {

        for (uint256 i_ = 0; i_ < notices_.length; i_++) {
            emit NewNotice(msg.sender, notices_[i_]);
        }
    }
}