// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "ds-test/test.sol";

import "./KwentaNFT.sol";

contract KwentaNFTTest is DSTest {
    KwentaNFT kwentaNFT;

    string constant uri = "";
    address[] to = ["", ""];

    /*************
     * Utilities *
     ************/
    function setUp() public {
        kwentaNFT = new KwentaNFT(uri);
    }

    function 

    /****************
     * Sanity tests *
     ***************/
    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

    /******************
     * Contract tests *
     *****************/
    function testDistribute(address[] calldata _to, uint256[] calldata _tiers)
        public
    {
        kwentaNFT.distribute(_to, _tiers);

        assertTrue(kwentaNFT.hasDistributed == true);
    }
}
