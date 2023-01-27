
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// UNLICENSED
pragma solidity ^0.8.0;


interface ITraitOracle {

    function hasTrait(
        IERC721 _tokenContract,
        uint256 _tokenId,
        bytes calldata _trait
    ) external view returns (bool);

}// UNLICENSED
pragma solidity ^0.8.0;


contract CircuitOracle is ITraitOracle {

    uint256 internal constant OP_STOP = 0x00;
    uint256 internal constant OP_NOT = 0x01;
    uint256 internal constant OP_OR = 0x02;
    uint256 internal constant OP_AND = 0x03;

    string internal constant ERR_OVERRUN_BASE_TRAIT =
        "CircuitOracle: base trait buffer overrun";
    string internal constant ERR_OVERRUN_ARG =
        "CircuitOracle: arg buffer overrun";

    function hasTrait(
        IERC721 _tokenContract,
        uint256 _tokenId,
        bytes calldata _buf
    ) external view override returns (bool) {

        (ITraitOracle _delegate, uint256 _traitLengths, uint256 _ops) = abi
            .decode(_buf, (ITraitOracle, uint256, uint256));
        uint256 _bufIdx = 96; // read-offset into dynamic part of `_buf`

        uint256 _mem = 0; // `_mem & (1 << _i)` stores variable `_i`
        uint256 _v = 0; // next variable to assign

        while (true) {
            uint256 _traitLength = _traitLengths & 0xffff;
            _traitLengths >>= 16;
            if (_traitLength == 0) break;
            _traitLength = uncheckedSub(_traitLength, 1);

            if (_bufIdx + _traitLength > _buf.length)
                revert(ERR_OVERRUN_BASE_TRAIT);
            bool _hasTrait = _delegate.hasTrait(
                _tokenContract,
                _tokenId,
                _buf[_bufIdx:_bufIdx + _traitLength]
            );
            _bufIdx += _traitLength;
            _mem |= boolToUint256(_hasTrait) << _v;
            _v = uncheckedAdd(_v, 1);
        }

        while (true) {
            uint256 _op = _ops & 0x03;
            _ops >>= 2;
            if (_op == OP_STOP) break;

            bool _output;
            if (_op == OP_NOT) {
                uint256 _idx0 = _bufIdx;
                _bufIdx = uncheckedAdd(_bufIdx, 1);

                if (_buf.length < _bufIdx) revert(ERR_OVERRUN_ARG);
                bool _v0 = (_mem & (1 << uint256(uint8(_buf[_idx0])))) != 0;
                _output = !_v0;
            } else {
                uint256 _idx0 = _bufIdx;
                uint256 _idx1 = uncheckedAdd(_bufIdx, 1);
                _bufIdx = uncheckedAdd(_bufIdx, 2);

                if (_buf.length < _bufIdx) revert(ERR_OVERRUN_ARG);
                bool _v0 = (_mem & (1 << uint256(uint8(_buf[_idx0])))) != 0;
                bool _v1 = (_mem & (1 << uint256(uint8(_buf[_idx1])))) != 0;
                if (_op == OP_OR) {
                    _output = _v0 || _v1;
                } else {
                    _output = _v0 && _v1;
                }
            }

            _mem |= boolToUint256(_output) << _v;
            _v = uncheckedAdd(_v, 1);
        }

        if (_v == 0) return false; // no base traits or ops
        return (_mem & (1 << uncheckedSub(_v, 1))) != 0;
    }

    function uncheckedAdd(uint256 _a, uint256 _b)
        internal
        pure
        returns (uint256)
    {

        unchecked {
            return _a + _b;
        }
    }

    function uncheckedSub(uint256 _a, uint256 _b)
        internal
        pure
        returns (uint256)
    {

        unchecked {
            return _a - _b;
        }
    }

    function boolToUint256(bool _b) internal pure returns (uint256 _x) {

        assembly {
            _x := _b
        }
    }
}