pragma solidity ^0.8.0;

interface IInflateLib {


    enum ErrorCode {
        ERR_NONE, // 0 successful inflate
        ERR_NOT_TERMINATED, // 1 available inflate data did not terminate
        ERR_OUTPUT_EXHAUSTED, // 2 output space exhausted before completing inflate
        ERR_INVALID_BLOCK_TYPE, // 3 invalid block type (type == 3)
        ERR_STORED_LENGTH_NO_MATCH, // 4 stored block length did not match one's complement
        ERR_TOO_MANY_LENGTH_OR_DISTANCE_CODES, // 5 dynamic block code description: too many length or distance codes
        ERR_CODE_LENGTHS_CODES_INCOMPLETE, // 6 dynamic block code description: code lengths codes incomplete
        ERR_REPEAT_NO_FIRST_LENGTH, // 7 dynamic block code description: repeat lengths with no first length
        ERR_REPEAT_MORE, // 8 dynamic block code description: repeat more than specified lengths
        ERR_INVALID_LITERAL_LENGTH_CODE_LENGTHS, // 9 dynamic block code description: invalid literal/length code lengths
        ERR_INVALID_DISTANCE_CODE_LENGTHS, // 10 dynamic block code description: invalid distance code lengths
        ERR_MISSING_END_OF_BLOCK, // 11 dynamic block code description: missing end-of-block code
        ERR_INVALID_LENGTH_OR_DISTANCE_CODE, // 12 invalid literal/length or distance code in fixed or dynamic block
        ERR_DISTANCE_TOO_FAR, // 13 distance is too far back in fixed or dynamic block
        ERR_CONSTRUCT // 14 internal: error in construct()
    }

    function puffFromOffset(bytes calldata source, uint256 destlen, uint256 offset)
        external
        pure
        returns (ErrorCode, bytes memory);


    function puff(bytes calldata source, uint256 destlen)
        external
        pure
        returns (ErrorCode, bytes memory);


    function smartDecode(bytes calldata source)
        external 
        pure
        returns (ErrorCode, bytes memory);


}// Apache-2.0
pragma solidity ^0.8.0;



library InflateLib {

    uint256 constant MAXBITS = 15;
    uint256 constant MAXLCODES = 286;
    uint256 constant MAXDCODES = 30;
    uint256 constant MAXCODES = (MAXLCODES + MAXDCODES);
    uint256 constant FIXLCODES = 288;

    struct State {
        bytes output;
        uint256 outcnt;
        bytes input;
        uint256 incnt;
        uint256 bitbuf;
        uint256 bitcnt;
        Huffman lencode;
        Huffman distcode;
    }

    struct Huffman {
        uint256[] counts;
        uint256[] symbols;
    }

    function bits(State memory s, uint256 need)
        private
        pure
        returns (IInflateLib.ErrorCode, uint256)
    {

        uint256 val;

        val = s.bitbuf;
        while (s.bitcnt < need) {
            if (s.incnt == s.input.length) {
                return (IInflateLib.ErrorCode.ERR_NOT_TERMINATED, 0);
            }

            val |= uint256(uint8(s.input[s.incnt++])) << s.bitcnt;
            s.bitcnt += 8;
        }

        s.bitbuf = val >> need;
        s.bitcnt -= need;

        uint256 ret = (val & ((1 << need) - 1));
        return (IInflateLib.ErrorCode.ERR_NONE, ret);
    }

    function _stored(State memory s) private pure returns (IInflateLib.ErrorCode) {

        uint256 len;

        s.bitbuf = 0;
        s.bitcnt = 0;

        if (s.incnt + 4 > s.input.length) {
            return IInflateLib.ErrorCode.ERR_NOT_TERMINATED;
        }
        len = uint256(uint8(s.input[s.incnt++]));
        len |= uint256(uint8(s.input[s.incnt++])) << 8;

        if (
            uint8(s.input[s.incnt++]) != (~len & 0xFF) ||
            uint8(s.input[s.incnt++]) != ((~len >> 8) & 0xFF)
        ) {
            return IInflateLib.ErrorCode.ERR_STORED_LENGTH_NO_MATCH;
        }

        if (s.incnt + len > s.input.length) {
            return IInflateLib.ErrorCode.ERR_NOT_TERMINATED;
        }
        if (s.outcnt + len > s.output.length) {
            return IInflateLib.ErrorCode.ERR_OUTPUT_EXHAUSTED;
        }
        while (len != 0) {
            len -= 1;
            s.output[s.outcnt++] = s.input[s.incnt++];
        }

        return IInflateLib.ErrorCode.ERR_NONE;
    }

    function _decode(State memory s, Huffman memory h)
        private
        pure
        returns (IInflateLib.ErrorCode, uint256)
    {

        uint256 len;
        uint256 code = 0;
        uint256 first = 0;
        uint256 count;
        uint256 index = 0;
        IInflateLib.ErrorCode err;

        for (len = 1; len <= MAXBITS; len++) {
            uint256 tempCode;
            (err, tempCode) = bits(s, 1);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return (err, 0);
            }
            code |= tempCode;
            count = h.counts[len];

            if (code < first + count) {
                return (IInflateLib.ErrorCode.ERR_NONE, h.symbols[index + (code - first)]);
            }
            index += count;
            first += count;
            first <<= 1;
            code <<= 1;
        }

        return (IInflateLib.ErrorCode.ERR_INVALID_LENGTH_OR_DISTANCE_CODE, 0);
    }

    function _construct(
        Huffman memory h,
        uint256[] memory lengths,
        uint256 n,
        uint256 start
    ) private pure returns (IInflateLib.ErrorCode) {

        uint256 symbol;
        uint256 len;
        uint256 left;
        uint256[MAXBITS + 1] memory offs;

        for (len = 0; len <= MAXBITS; len++) {
            h.counts[len] = 0;
        }
        for (symbol = 0; symbol < n; symbol++) {
            h.counts[lengths[start + symbol]]++;
        }
        if (h.counts[0] == n) {
            return (IInflateLib.ErrorCode.ERR_NONE);
        }


        left = 1;

        for (len = 1; len <= MAXBITS; len++) {
            left <<= 1;
            if (left < h.counts[len]) {
                return IInflateLib.ErrorCode.ERR_CONSTRUCT;
            }

            left -= h.counts[len];
        }

        offs[1] = 0;
        for (len = 1; len < MAXBITS; len++) {
            offs[len + 1] = offs[len] + h.counts[len];
        }

        for (symbol = 0; symbol < n; symbol++) {
            if (lengths[start + symbol] != 0) {
                h.symbols[offs[lengths[start + symbol]]++] = symbol;
            }
        }

        return left > 0 ? IInflateLib.ErrorCode.ERR_CONSTRUCT : IInflateLib.ErrorCode.ERR_NONE;
    }

    function _codes(
        State memory s,
        Huffman memory lencode,
        Huffman memory distcode
    ) private pure returns (IInflateLib.ErrorCode) {

        uint256 symbol;
        uint256 len;
        uint256 dist;
        uint16[29] memory lens =
            [
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                13,
                15,
                17,
                19,
                23,
                27,
                31,
                35,
                43,
                51,
                59,
                67,
                83,
                99,
                115,
                131,
                163,
                195,
                227,
                258
            ];
        uint8[29] memory lext =
            [
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                1,
                1,
                1,
                1,
                2,
                2,
                2,
                2,
                3,
                3,
                3,
                3,
                4,
                4,
                4,
                4,
                5,
                5,
                5,
                5,
                0
            ];
        uint16[30] memory dists =
            [
                1,
                2,
                3,
                4,
                5,
                7,
                9,
                13,
                17,
                25,
                33,
                49,
                65,
                97,
                129,
                193,
                257,
                385,
                513,
                769,
                1025,
                1537,
                2049,
                3073,
                4097,
                6145,
                8193,
                12289,
                16385,
                24577
            ];
        uint8[30] memory dext =
            [
                0,
                0,
                0,
                0,
                1,
                1,
                2,
                2,
                3,
                3,
                4,
                4,
                5,
                5,
                6,
                6,
                7,
                7,
                8,
                8,
                9,
                9,
                10,
                10,
                11,
                11,
                12,
                12,
                13,
                13
            ];
        IInflateLib.ErrorCode err;

        while (symbol != 256) {
            (err, symbol) = _decode(s, lencode);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return err;
            }

            if (symbol < 256) {
                if (s.outcnt == s.output.length) {
                    return IInflateLib.ErrorCode.ERR_OUTPUT_EXHAUSTED;
                }
                s.output[s.outcnt] = bytes1(uint8(symbol));
                s.outcnt++;
            } else if (symbol > 256) {
                uint256 tempBits;
                symbol -= 257;
                if (symbol >= 29) {
                    return IInflateLib.ErrorCode.ERR_INVALID_LENGTH_OR_DISTANCE_CODE;
                }

                (err, tempBits) = bits(s, lext[symbol]);
                if (err != IInflateLib.ErrorCode.ERR_NONE) {
                    return err;
                }
                len = lens[symbol] + tempBits;

                (err, symbol) = _decode(s, distcode);
                if (err != IInflateLib.ErrorCode.ERR_NONE) {
                    return err;
                }
                (err, tempBits) = bits(s, dext[symbol]);
                if (err != IInflateLib.ErrorCode.ERR_NONE) {
                    return err;
                }
                dist = dists[symbol] + tempBits;
                if (dist > s.outcnt) {
                    return IInflateLib.ErrorCode.ERR_DISTANCE_TOO_FAR;
                }

                if (s.outcnt + len > s.output.length) {
                    return IInflateLib.ErrorCode.ERR_OUTPUT_EXHAUSTED;
                }
                while (len != 0) {
                    len -= 1;
                    s.output[s.outcnt] = s.output[s.outcnt - dist];
                    s.outcnt++;
                }
            } else {
                s.outcnt += len;
            }
        }

        return IInflateLib.ErrorCode.ERR_NONE;
    }

    function _build_fixed(State memory s) private pure returns (IInflateLib.ErrorCode) {

        uint256 symbol;
        uint256[] memory lengths = new uint256[](FIXLCODES);

        for (symbol = 0; symbol < 144; symbol++) {
            lengths[symbol] = 8;
        }
        for (; symbol < 256; symbol++) {
            lengths[symbol] = 9;
        }
        for (; symbol < 280; symbol++) {
            lengths[symbol] = 7;
        }
        for (; symbol < FIXLCODES; symbol++) {
            lengths[symbol] = 8;
        }

        _construct(s.lencode, lengths, FIXLCODES, 0);

        for (symbol = 0; symbol < MAXDCODES; symbol++) {
            lengths[symbol] = 5;
        }

        _construct(s.distcode, lengths, MAXDCODES, 0);

        return IInflateLib.ErrorCode.ERR_NONE;
    }

    function _fixed(State memory s) private pure returns (IInflateLib.ErrorCode) {

        return _codes(s, s.lencode, s.distcode);
    }

    function _build_dynamic_lengths(State memory s)
        private
        pure
        returns (IInflateLib.ErrorCode, uint256[] memory)
    {

        uint256 ncode;
        uint256 index;
        uint256[] memory lengths = new uint256[](MAXCODES);
        IInflateLib.ErrorCode err;
        uint8[19] memory order =
            [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];

        (err, ncode) = bits(s, 4);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (err, lengths);
        }
        ncode += 4;

        for (index = 0; index < ncode; index++) {
            (err, lengths[order[index]]) = bits(s, 3);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return (err, lengths);
            }
        }
        for (; index < 19; index++) {
            lengths[order[index]] = 0;
        }

        return (IInflateLib.ErrorCode.ERR_NONE, lengths);
    }

    function _build_dynamic(State memory s)
        private
        pure
        returns (
            IInflateLib.ErrorCode,
            Huffman memory,
            Huffman memory
        )
    {

        uint256 nlen;
        uint256 ndist;
        uint256 index;
        IInflateLib.ErrorCode err;
        uint256[] memory lengths = new uint256[](MAXCODES);
        Huffman memory lencode =
            Huffman(new uint256[](MAXBITS + 1), new uint256[](MAXLCODES));
        Huffman memory distcode =
            Huffman(new uint256[](MAXBITS + 1), new uint256[](MAXDCODES));
        uint256 tempBits;

        (err, nlen) = bits(s, 5);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (err, lencode, distcode);
        }
        nlen += 257;
        (err, ndist) = bits(s, 5);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (err, lencode, distcode);
        }
        ndist += 1;

        if (nlen > MAXLCODES || ndist > MAXDCODES) {
            return (
                IInflateLib.ErrorCode.ERR_TOO_MANY_LENGTH_OR_DISTANCE_CODES,
                lencode,
                distcode
            );
        }

        (err, lengths) = _build_dynamic_lengths(s);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (err, lencode, distcode);
        }

        err = _construct(lencode, lengths, 19, 0);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (
                IInflateLib.ErrorCode.ERR_CODE_LENGTHS_CODES_INCOMPLETE,
                lencode,
                distcode
            );
        }

        index = 0;
        while (index < nlen + ndist) {
            uint256 symbol;
            uint256 len;

            (err, symbol) = _decode(s, lencode);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return (err, lencode, distcode);
            }

            if (symbol < 16) {
                lengths[index++] = symbol;
            } else {
                len = 0;
                if (symbol == 16) {
                    if (index == 0) {
                        return (
                            IInflateLib.ErrorCode.ERR_REPEAT_NO_FIRST_LENGTH,
                            lencode,
                            distcode
                        );
                    }
                    len = lengths[index - 1];
                    (err, tempBits) = bits(s, 2);
                    if (err != IInflateLib.ErrorCode.ERR_NONE) {
                        return (err, lencode, distcode);
                    }
                    symbol = 3 + tempBits;
                } else if (symbol == 17) {
                    (err, tempBits) = bits(s, 3);
                    if (err != IInflateLib.ErrorCode.ERR_NONE) {
                        return (err, lencode, distcode);
                    }
                    symbol = 3 + tempBits;
                } else {
                    (err, tempBits) = bits(s, 7);
                    if (err != IInflateLib.ErrorCode.ERR_NONE) {
                        return (err, lencode, distcode);
                    }
                    symbol = 11 + tempBits;
                }

                if (index + symbol > nlen + ndist) {
                    return (IInflateLib.ErrorCode.ERR_REPEAT_MORE, lencode, distcode);
                }
                while (symbol != 0) {
                    symbol -= 1;

                    lengths[index++] = len;
                }
            }
        }

        if (lengths[256] == 0) {
            return (IInflateLib.ErrorCode.ERR_MISSING_END_OF_BLOCK, lencode, distcode);
        }

        err = _construct(lencode, lengths, nlen, 0);
        if (
            err != IInflateLib.ErrorCode.ERR_NONE &&
            (err == IInflateLib.ErrorCode.ERR_NOT_TERMINATED ||
                err == IInflateLib.ErrorCode.ERR_OUTPUT_EXHAUSTED ||
                nlen != lencode.counts[0] + lencode.counts[1])
        ) {
            return (
                IInflateLib.ErrorCode.ERR_INVALID_LITERAL_LENGTH_CODE_LENGTHS,
                lencode,
                distcode
            );
        }

        err = _construct(distcode, lengths, ndist, nlen);
        if (
            err != IInflateLib.ErrorCode.ERR_NONE &&
            (err == IInflateLib.ErrorCode.ERR_NOT_TERMINATED ||
                err == IInflateLib.ErrorCode.ERR_OUTPUT_EXHAUSTED ||
                ndist != distcode.counts[0] + distcode.counts[1])
        ) {
            return (
                IInflateLib.ErrorCode.ERR_INVALID_DISTANCE_CODE_LENGTHS,
                lencode,
                distcode
            );
        }

        return (IInflateLib.ErrorCode.ERR_NONE, lencode, distcode);
    }

    function _dynamic(State memory s) private pure returns (IInflateLib.ErrorCode) {

        Huffman memory lencode;
        Huffman memory distcode;
        IInflateLib.ErrorCode err;

        (err, lencode, distcode) = _build_dynamic(s);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return err;
        }

        return _codes(s, lencode, distcode);
    }

    function puffFromOffset(bytes calldata source, uint256 destlen, uint256 offset)
        public
        pure
        returns (IInflateLib.ErrorCode, bytes memory)
    {

        State memory s =
            State(
                new bytes(destlen),
                0,
                source,
                offset,
                0,
                0,
                Huffman(new uint256[](MAXBITS + 1), new uint256[](FIXLCODES)),
                Huffman(new uint256[](MAXBITS + 1), new uint256[](MAXDCODES))
            );
        uint256 last;
        uint256 t;
        IInflateLib.ErrorCode err;

        err = _build_fixed(s);
        if (err != IInflateLib.ErrorCode.ERR_NONE) {
            return (err, s.output);
        }

        while (last == 0) {
            (err, last) = bits(s, 1);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return (err, s.output);
            }

            (err, t) = bits(s, 2);
            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                return (err, s.output);
            }

            err = (
                t == 0
                    ? _stored(s)
                    : (
                        t == 1
                            ? _fixed(s)
                            : (
                                t == 2
                                    ? _dynamic(s)
                                    : IInflateLib.ErrorCode.ERR_INVALID_BLOCK_TYPE
                            )
                    )
            );

            if (err != IInflateLib.ErrorCode.ERR_NONE) {
                break;
            }
        }

        return (err, s.output);
    }

    function puff(bytes calldata source, uint256 destlen)
        external
        pure
        returns (IInflateLib.ErrorCode, bytes memory)
    {

        return puffFromOffset(source, destlen, 0);
    }

    function smartDecode(bytes calldata source)
        external 
        pure
        returns (IInflateLib.ErrorCode, bytes memory) {

            if((source[0] == 0x1f) && (source[1] == 0x8b)) {

                return puffFromOffset(source, uint256(uint8(source[2])) << 16 | uint256(uint8(source[3])) << 8 | uint256(uint8(source[4])), 5);

            } else {

                return (IInflateLib.ErrorCode.ERR_NONE, source);
            }
        }


}