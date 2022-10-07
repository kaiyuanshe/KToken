// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

contract FDUVISerNFT is ERC721, ERC721Enumerable, Ownable {
    mapping(string => bool) private takenNames;
    mapping(uint256 => Attr) public attributes;

    struct Attr {
        string name;
        string date;
    }

    constructor() ERC721("FDUVISer", "FDUVIS") {}

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mint(
        address to, 
        uint256 tokenId, 
        string memory _name, 
        string memory _date) 
    public onlyOwner {
        _safeMint(to, tokenId);
        attributes[tokenId] = Attr(_name, _date);
    }

    function getSvg(uint tokenId) private view returns (string memory) {
        string memory svg;
        svg = "<svg version='1.0' xmlns='http://www.w3.org/2000/svg' width='640.000000pt' height='640.000000pt' viewBox='0 0 640.000000 640.000000' preserveAspectRatio='xMidYMid meet'> <metadata> Created by potrace 1.16, written by Peter Selinger 2001-2019 </metadata> <g transform='translate(0.000000,640.000000) scale(0.100000,-0.100000)' fill='#000000' stroke='none'> <path d='M3620 5085 c-144 -19 -416 -88 -455 -115 -5 -4 -28 -13 -50 -20 -55 -17 -213 -97 -310 -155 -334 -202 -624 -530 -772 -875 -62 -145 -111 -310 -129 -432 -3 -27 -9 -48 -12 -48 -3 0 -42 9 -86 21 -641 163 -720 180 -780 174 -161 -16 -268 -79 -328 -195 -32 -63 -32 -175 1 -240 28 -53 92 -135 135 -170 30 -25 45 -29 796 -222 564 -144 602 -150 715 -107 130 49 236 208 214 324 -31 169 -33 220 -16 336 22 146 54 246 116 370 66 131 126 213 240 332 171 177 376 307 596 378 172 55 231 64 435 64 172 0 205 -3 280 -24 149 -40 288 -116 445 -241 153 -122 182 -138 266 -147 123 -13 240 58 294 178 24 55 27 71 22 128 -9 107 -57 190 -162 282 -216 188 -492 320 -802 384 -109 23 -159 27 -338 31 -144 2 -243 -1 -315 -11z'/> <path d='M933 4970 c-142 -67 -157 -262 -29 -393 39 -40 303 -225 458 -322 9 -5 53 -35 99 -66 198 -132 226 -147 283 -158 116 -21 215 20 262 110 9 19 16 57 16 95 1 124 -43 179 -281 352 -350 256 -514 367 -572 387 -61 22 -184 19 -236 -5z'/> <path d='M3701 3819 c-56 -11 -143 -39 -155 -50 -5 -4 -12 -89 -17 -189 -18 -419 -21 -460 -36 -460 -11 0 -12 15 -7 80 5 54 3 80 -4 80 -6 0 -13 -37 -17 -87 -7 -97 -12 -119 -23 -109 -4 4 -5 50 -3 103 3 88 2 95 -15 91 -16 -3 -19 -14 -22 -63 -3 -84 -12 -129 -22 -119 -10 11 -16 171 -6 181 3 3 6 -2 7 -13 1 -14 3 -13 8 6 7 25 9 26 87 29 20 1 21 8 28 179 4 97 9 201 13 231 l6 54 -44 -26 c-142 -85 -251 -231 -293 -393 -21 -79 -21 -124 -1 -124 10 0 16 -11 16 -32 2 -30 2 -30 6 -6 6 37 27 53 46 34 13 -14 16 -9 22 39 6 51 8 55 29 49 17 -4 25 1 35 23 13 26 14 27 22 8 4 -11 8 -27 8 -35 -1 -10 -2 -11 -6 -2 -10 24 -23 0 -23 -42 0 -71 -12 -166 -21 -166 -5 0 -9 42 -9 94 0 52 -4 97 -9 100 -10 6 -21 -74 -21 -151 0 -54 -13 -71 -24 -30 -3 12 -6 41 -6 65 0 23 -4 42 -9 42 -9 0 -16 -48 -27 -187 -7 -80 -6 -82 30 -147 68 -122 200 -242 321 -293 99 -41 187 -56 298 -50 178 10 311 69 432 191 75 77 137 180 161 269 16 59 19 217 5 217 -15 0 -20 -13 -22 -63 -3 -52 -15 -81 -23 -57 -3 8 -7 53 -9 100 -6 106 -27 124 -27 22 0 -81 -9 -134 -21 -126 -5 3 -9 33 -10 67 -1 34 -4 86 -7 116 -6 49 -8 53 -21 37 -11 -14 -14 -42 -12 -117 2 -81 0 -99 -12 -99 -11 0 -16 23 -22 106 -4 61 -11 102 -16 97 -5 -5 -12 -54 -16 -108 -5 -55 -12 -100 -18 -100 -5 0 -12 32 -15 71 l-5 72 -79 -51 c-76 -49 -83 -51 -145 -50 -98 1 -126 7 -129 27 -4 16 -5 16 -18 -1 -12 -16 -13 -15 -14 20 0 20 -4 37 -10 37 -5 0 -10 -18 -10 -40 0 -22 -5 -40 -10 -40 -7 0 -8 65 -3 190 4 141 3 190 -5 190 -9 0 -12 -44 -13 -152 0 -154 -10 -256 -20 -228 -3 8 -2 132 2 275 10 349 10 425 2 424 -5 -1 -28 -5 -52 -10z'/> <path d='M3780 3681 l0 -151 55 0 56 0 -3 148 -3 147 -52 3 -53 3 0 -150z'/> <path d='M3917 3683 c-2 -76 -3 -140 -2 -142 8 -7 196 190 193 202 -5 16 -103 62 -149 71 l-36 6 -6 -137z'/> <path d='M3811 3480 l1 -45 10 34 c6 23 6 37 -1 44 -8 8 -11 -2 -10 -33z'/> <path d='M3870 3504 c0 -8 5 -12 10 -9 6 3 10 10 10 16 0 5 -4 9 -10 9 -5 0 -10 -7 -10 -16z'/> <path d='M3840 3490 c0 -11 4 -20 9 -20 6 0 9 9 8 20 -1 11 -5 20 -9 20 -4 0 -8 -9 -8 -20z'/> <path d='M4361 3396 c-33 -34 -39 -45 -27 -49 8 -3 18 -17 22 -31 5 -22 9 -24 31 -15 34 13 38 7 34 -49 -2 -38 0 -45 10 -34 7 6 21 12 30 12 14 0 16 7 12 38 -10 82 -42 172 -62 172 -4 0 -26 -20 -50 -44z'/> <path d='M4292 3328 c-7 -7 -12 -18 -12 -25 0 -8 7 -6 20 7 11 11 20 22 20 25 0 9 -16 5 -28 -7z'/> <path d='M5333 3210 c-22 -5 -59 -18 -81 -29 -52 -26 -139 -125 -154 -173 -6 -21 -14 -38 -18 -38 -4 0 -5 -13 -2 -28 5 -38 -57 -204 -119 -317 -198 -361 -529 -594 -945 -665 -214 -37 -444 -17 -661 55 -94 32 -282 123 -344 168 -96 69 -229 70 -335 2 -54 -35 -76 -61 -115 -135 -19 -37 -23 -60 -23 -130 0 -139 45 -203 218 -315 289 -187 634 -285 1006 -286 332 0 608 65 895 212 373 191 676 496 868 876 94 186 131 292 181 516 8 35 -36 126 -90 185 -77 86 -178 122 -281 102z'/> <path d='M3165 3146 c15 -114 23 -126 24 -33 1 73 -2 87 -15 87 -13 0 -14 -9 -9 -54z'/> </g> </svg>";
        return svg;
    }    

    function tokenURI(uint256 tokenId) override(ERC721) public view returns (string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', attributes[tokenId].name, '",',
                    '"image_data": "', getSvg(tokenId), '",',
                    '"date": "', attributes[tokenId].name, '"}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }    
}