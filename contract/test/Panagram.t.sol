//SPDX-License-Identifier:MIT 

pragma solidity ^0.8.24;


import {Test,console} from "forge-std/Test.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";


contract PanagramTest is Test {

    HonkVerifier public verifier;
    Panagram public panagram;
    address  user = makeAddr("user");
    uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 ANSWER = bytes32(uint256(keccak256("triangles"))%FIELD_MODULUS);

function setup() public {

    verifier = new HonkVerifier();

    panagram = new Panagram(verifier);

    panagram.newRound(ANSWER);


}


function _getProof(bytes32  guess, bytes32 correctAnswer) internal returns (bytes memory proof){
uint256 NUM_ARGS =5;
string [] memory inputs = new string [](NUM_ARGS); 

inputs [0] = "npx";
inputs [1] = "tsx";
inputs [2] = "js-scripts/generateProof.ts";
inputs [3] = vm.toString(guess);
inputs [4] = vm.toString(correctAnswer);

bytes memory result = vm.ffi(inputs);

} 

function  testCorrectGuessPasses() public {

    vm.prank(user);
    panagram.makeGuess(proof);

}
}