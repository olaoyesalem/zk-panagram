
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";


contract Panagram is ERC1155,Ownable {
event Panagram_VerifierUpdated(IVerifier newVerifier);

  IVerifier public  immutable ∆;

    // Token IDs
    uint256 public constant WINNER_ID = 0;
    uint256 public constant RUNNER_UP_ID = 1;

    constructor (IVerifier _verifier)
        ERC1155("ipfs://bafybeib2p7wtfwcokldrw2lt7hdd2c746b2r5wrntlrgqbbf6gff66duxm/{id}.json")
        Ownable(msg.sender)
    {
        verifier = _verifier;
    }


    // function to create a new round of the game

    // function to allow users submit a guess

    // set a new verifier 

    function setVerifier(IVerifier _verifier) external onlyOwner {
        verifier = _verifier;
        emit Panagram_VerifierUpdated(_verifier);
    }

}