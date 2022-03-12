// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./KwentaNft2.sol";

contract KwentaNft2Test is DSTest {
    KwentaNft2 nft;

    function setUp() public {
        nft = new KwentaNft2();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
