import { Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import { UltraHonkBackend } from "@aztec/bb.js";
import fs from "fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const circuitPath = path.resolve(
    __dirname,
    "../../circuit/target/Panagram.json"
);

const circuit = JSON.parse(
    fs.readFileSync(circuitPath, "utf8")
);

async function generateProof() {
    const inputsArray = process.argv.slice(2);

    try {
        if (inputsArray.length < 2) {
            throw new Error(
                "Expected two arguments: guess_hash and answer_hash"
            );
        }

        // Initialize Noir with compiled circuit
        const noir = new Noir(circuit);

        // Initialize UltraHonk proving backend
        const bb = new UltraHonkBackend(
            circuit.bytecode,
            { threads: 1 }
        );

        // IMPORTANT:
        // Names must exactly match the Noir circuit arguments.
        const inputs = {
            guess_hash: inputsArray[0],
            answer_hash: inputsArray[1],
        };

        // Generate witness
        const { witness } = await noir.execute(inputs);

        // bb.js may print logs, so silence stdout temporarily.
        const originalLog = console.log;
        console.log = () => {};

        const { proof } = await bb.generateProof(witness, {
            keccak: true,
        });

        console.log = originalLog;

        // ABI encode because Solidity will decode this as bytes.
        const proofEncoded =
            ethers.AbiCoder.defaultAbiCoder().encode(
                ["bytes"],
                [proof]
            );

        return proofEncoded;

    } catch (error) {
        // stderr is safe for debugging.
        console.error(error);
        throw error;
    }
}

generateProof()
    .then((proof) => {
        // IMPORTANT:
        // This should be the only stdout output.
        process.stdout.write(proof);
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });