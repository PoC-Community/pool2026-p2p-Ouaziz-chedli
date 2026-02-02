// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISmartContract {
    event BalanceUpdated(address indexed user, uint256 newBalance);
    error InsufficientBalance(uint256 available, uint256 requested);

    // Define the struct
    struct Person {
        string name;
        uint8 age;
    }

    enum roleEnum {
        STUDENT,
        TEACHER
    }

    struct informations {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        roleEnum role;
    }
    // Declare types, events, errors, and function signatures
    // (no implementation!)
}
