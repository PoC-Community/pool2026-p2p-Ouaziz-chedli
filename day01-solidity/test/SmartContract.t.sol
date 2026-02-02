// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/SmartContract.sol" as x;

contract SmartContractHelper is x.SmartContract {
    // Expose internal functions as public
    function getAreYouABadPerson() public view returns (bool) {
        return _areYouABadPerson; // Access internal variable
    }
}

import "forge-std/Test.sol" as f;

contract MyTest is f.Test {
    SmartContractHelper smartContract;

    function setUp() public {
        smartContract = new SmartContractHelper();
        // Setup code here
    }

    function testSomething() public {
        uint256 actual = smartContract.getHalfAnswerOfLife();
        uint256 expected = 21;
        assertEq(actual, expected); // Check equality
    }
}
