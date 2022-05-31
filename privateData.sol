//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

// source - https://solidity-by-example.org/ (amazing resource)

// Accessing the state variables of a contract using web3 
// No data on blockchain is hidden whether its private/internal/public

/* Understanding how storage works. Storage --> 32bytes width * 2**256 height avaliable
    data stored is sequentially in order of decleration.
    storage is optimized to save space. If neighboring variables fit in a single
    32 bytes, then they are packed into the same slot, starting from the right
*/
contract stateVariables{
    // slot 0 - uses all 32 bytes
    uint public count = 123;

    // slot 1 - uses 20 bytes
    address public owner = msg.sender;
    //uses 1 byte (slot 1) 
    bool public isTrue = true;
    // uses 10 bytes (slot1)
    uint80 public u18 = 212;

    // slot 2 - uses all 32 bytes
    bytes32 private password;

    //constants do not use storage (stored in evm code)
    uint public constant someConstant = 1234;

    //slot 3 , 4 , 5
    bytes32[3] public data;

    // uses 2 slots
    struct user{
        uint id;
        bytes32 password;
    }

    // dynamic array
    // slot 6 - length is stored
    // array elements - starting form hash(6)
    // slot of element at index n = hash(6) + n*2 (2 for each streuct user)
    user[] private users;

    // slot 7 empty
    // entries are stored at hash(key , slot)
    // slot = 7 and key = map key
    mapping(uint => user) private isTouser;
}

/*
    web3/ethers.js functions
    to get value of storage at a slot
    web3.eth.getStorageAt("address of contract" , slot , fallback(console.log))
    ethersProvider.getStorageAt

    web3.toAscii to convert bytes32 to alphabet
    web3.utils.numberToHex
*/