// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ISmartContract.sol" as x;

contract SmartContract is x.ISmartContract {
    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public PoCIsWhat = "PoC is good, PoC is life.";

    bool internal _areYouABadPerson = false;

    int256 private _youAreACheater = -42;

    // Create an instance
    Person public alice = Person({name: "Alice", age: 25});

    bytes32 whoIsTheBest;

    mapping(string => uint256) public myGrades;

    string[5] public myPhoneNumber;

    informations public myInformations;

    /**
     * @notice Returns halfAnswerOfLife
     * @dev TODO: Return the value of halfAnswerOfLife
     */
    function getHalfAnswerOfLife() public view returns (uint256) {
        return halfAnswerOfLife;
        // TODO: Implement
    }

    /**
     * @notice Returns the contract address (internal)
     * @dev TODO: Return myEthereumContractAddress
     */
    function _getMyEthereumContractAddress() internal view returns (address) {
        return myEthereumContractAddress;
        // TODO: Implement
    }

    /**
     * @notice Returns PoCIsWhat (external only)
     * @dev TODO: Return PoCIsWhat with memory keyword for string
     */
    function getPoCIsWhat() external view returns (string memory) {
        return PoCIsWhat;
        // TODO: Implement
    }

    /**
     * @notice Sets _areYouABadPerson (internal)
     * @dev TODO: Update the internal variable
     */
    function _setAreYouABadPerson(bool _value) internal {
        _areYouABadPerson = _value;
    }

    // Your code here
    function editMyCity(string calldata _newCity) public {
        myInformations.city = _newCity;
        // TODO: Update myInformations.city
    }

    function getMyFullName() public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    myInformations.firstName,
                    " ",
                    myInformations.lastName
                )
            );
        // TODO: Concatenate firstName + " " + lastName
        // Hint: Use abi.encodePacked() to concatenate strings
        // return string(abi.encodePacked(str1, " ", str2));
    }

    address private owner;

    constructor() {
        owner = msg.sender; // Set deployer as owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; // This is where the function code runs
    }

    function completeHalfAnswerOfLife() public onlyOwner {
        halfAnswerOfLife += 21;
        // Only owner can call this
    }

    function hashMyMessage(
        string calldata _message
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
        // TODO: return the message hashed with keccak256
    }

    mapping(address => uint256) public balances;

    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
        // TODO: Return balances[msg.sender]
    }

    function addToBalance() public payable {
        balances[msg.sender] += msg.value;
        emit BalanceUpdated(msg.sender, balances[msg.sender]);
        // TODO: Add msg.value to balances[msg.sender]
    }

    function withdrawFromBalance(uint256 _amount) public {
        // Usage
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance(balances[msg.sender], _amount);
        } else {
            balances[msg.sender] -= _amount;
            (bool success, ) = msg.sender.call{value: _amount}("");
            // In your functions:
            emit BalanceUpdated(msg.sender, balances[msg.sender]);
            require(success, "Transfer failed.");
        }
        // TODO:
        // 1. Check balance >= amount
        // 2. Subtract from balance FIRST (before transfer!)
        // 3. Transfer using call{value}
        // 4. Check success
    }
}
