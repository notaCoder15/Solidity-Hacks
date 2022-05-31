//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;


/* 
External contract referencing refers to using already deployed ethereum code to our smart contracts.
any address can be casted into specific contract, even if the contract at the address is not the one being casted.
This can be deceiving, especially when the author of the contract is trying to hide malicious code.
*/