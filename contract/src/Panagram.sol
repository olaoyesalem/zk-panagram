
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";


contract Panagram is ERC1155,Ownable {
event Panagram_VerifierUpdated(IVerifier newVerifier);
event Panagram_NewRound(bytes32 answer);
event Panagram__WinnerCrowned(address winner, uint256 round);
event Panagram__RunnerUpCrowned(address runnerUp, uint256 round);



// ERROR
error Panagram__MinTimeNotElapsed(uint256 minDuration, uint256 timeElapsed);
error Panagram__NoRoundWinner();
error Panagram__FirstPanagramRoundNotSet();
error Panagram__AlreadyGuessedCorrectly(uint256 round, address user);
error Panagram__InvalidProof();




 

  IVerifier public   s_verifier;

    
       // State variables
    bytes32 public s_answer;
    uint256 public constant WINNER_ID = 0;
    uint256 public constant RUNNER_UP_ID = 1;
    uint256 public  constant MIN_DURATION = 10800; // 3 hours in seconds
    uint256 public s_roundStartTime;
    address public s_currentRoundWinner;
    uint256 public  s_currentRound;
    mapping (address => uint256) public  s_lastCorrectGuessRound;

    constructor (IVerifier _verifier)
        ERC1155("ipfs://bafybeib2p7wtfwcokldrw2lt7hdd2c746b2r5wrntlrgqbbf6gff66duxm/{id}.json")
        Ownable(msg.sender)
    {
        s_verifier = _verifier;
    }



    // function to create a new round of the game

    function newRound(bytes32 _answer) external onlyOwner {

        if (s_roundStartTime == 0) {
            s_roundStartTime = block.timestamp;
              s_answer = _answer;
        } else {
           if( s_roundStartTime+ MIN_DURATION> block.timestamp){
          revert Panagram__MinTimeNotElapsed(MIN_DURATION, block.timestamp - s_roundStartTime);
           
        }
        if(s_currentRoundWinner == address(0)){
            revert Panagram__NoRoundWinner();
        }
      
      //RESET THE ROUND

      s_roundStartTime=block.timestamp;
      s_currentRoundWinner = address(0);
      s_answer =_answer;
           
    }
    s_currentRound++;   

    emit Panagram_NewRound(s_answer);
    }

    // function to allow users submit a guess


    function makeGuess(bytes memory _proof ) external returns (bool)
{
    //check whethere the first roiund has been initialized..

    if (s_currentRound ==0){
        revert Panagram__FirstPanagramRoundNotSet();
    }
    // check if the user has already guessed correctly before

    if (s_lastCorrectGuessRound[msg.sender] == s_currentRound) {
     revert Panagram__AlreadyGuessedCorrectly(s_currentRound,msg.sender);
    }

    // cehck the proof  and verify it eith the verifier contract

    bytes32 [] memory publicInputs = new bytes32[](1);
     publicInputs[0] = s_answer;
   

  bool proofResult =   s_verifier.verify(_proof, publicInputs );
  if(!proofResult){
    revert Panagram__InvalidProof();
    }
    s_lastCorrectGuessRound[msg.sender] = s_currentRound;



    //if correct check if they are first , if they are then mint NFT Id =0, if corrrct and not first, mint NFT =1;
    if (s_currentRoundWinner == address(0)) {
        s_currentRoundWinner = msg.sender;
        _mint(msg.sender, WINNER_ID, 1, "");

        emit Panagram__WinnerCrowned(msg.sender, s_currentRound);
    } else {
        _mint(msg.sender, RUNNER_UP_ID, 1, "");

        emit Panagram__RunnerUpCrowned(msg.sender, s_currentRound);
    }
    // set a new verifier 


}
    function setVerifier(IVerifier _verifier) external onlyOwner {
        s_verifier = _verifier;
        emit Panagram_VerifierUpdated(_verifier);
    }

}
