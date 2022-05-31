//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

// sources - https://solidity-by-example.org/ , https://blog.sigmaprime.io/solidity-security.html#delegatecall

/*
Front running refers to when users race code execution to obtain unexpected states.
An attacker can watch the transaction pool for transactions which may contain solutions 
to problems, modify or revoke the attacker's permissions or change a state in a contract 
which is undesirable for the attacker. The attacker can then get the data from this transaction 
and create a transaction of their own with a higher gasPrice and get their transaction included 
in a block before the original.

*/
// attackers can look for solutions in the txPool and can front run the original tx with a higher gas price
contract FindThisHash {
    bytes32 constant public hash = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor()  payable {} // load with ether

    function solve(bytes memory solution) public {
        // If you can find the pre image of the hash, receive 1000 ether
        require(hash == keccak256(solution));
        payable(msg.sender).transfer(1000 ether);
    }
}

//Prevention Techniques

/*
1) One method that can be employed is to create logic in the contract that places an upper bound on the gasPrice.
2) A more robust method is to use a commit-reveal scheme, whenever possible. Such a scheme dictates users send transactions
 with hidden information (typically a hash). After the transaction has been included in a block, the user sends a transaction 
 revealing the data that was sent (the reveal phase). 
*/