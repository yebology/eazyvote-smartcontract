// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {EazyVoteDeploy} from "../../script/EazyVoteDeploy.s.sol";
import {EazyVote} from "../../src/EazyVote.sol";

contract EazyVoteUnitTest is Test {
    //
    EazyVoteDeploy eazyVoteDeploy;
    EazyVote eazyVote;

    function setUp() public {
        eazyVoteDeploy = new EazyVoteDeploy();
        eazyVote = eazyVoteDeploy.run();
    }

    function testNewElectionHasBeenAdded() public {
        uint256 eazyVoteElectionTotalBefore = eazyVote.getElections().length;
        eazyVote.createNewElection(1, 2);
        uint256 eazyVoteElectionTotalAfter = eazyVote.getElections().length;
        assertEq(eazyVoteElectionTotalBefore, 0);
        assertEq(eazyVoteElectionTotalAfter, 1);
    }
    //
}