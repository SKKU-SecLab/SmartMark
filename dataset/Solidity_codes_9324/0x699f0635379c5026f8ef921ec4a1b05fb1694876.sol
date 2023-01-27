

pragma solidity 0.8.7;




contract MemoLogs {

    event MemoLog(string Memo);
    event MemoWithTitle(string Title, string Memo);
    event MemosWithTitle(string Title, string[] Memos);

    function memo(string memory memo_) public {

        emit MemoLog(memo_);
    }

    function memoWithTitle(string memory title, string memory memo_) public {

        emit MemoWithTitle(title, memo_);
    }

    function memosWithTitle(string memory title, string[] memory memos_)
        public
    {

        emit MemosWithTitle(title, memos_);
    }
}