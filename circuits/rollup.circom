pragma circom 2.0.0;

include "./merkle.circom";
include "../node_modules/circomlib/circuits/mimc.circom";
include "../node_modules/circomlib/circuits/mimcsponge.circom";

template Rollup() {
    var levels = 2; // depth of merkle tree
    signal input sk;
    signal output pkLeaf;
    // signal input merkleRoot;
    // signal input merklePathElements[levels];
    // signal input merklePathIndices[levels];
    
    // verify that the pubkeyLeaf passed as input is in the merkle tree
    // component merkle = MerkleTreeChecker(levels);
    // merkle.root <== merkleRoot;
    // merkle.leaf <== pkLeaf;
    // merkle.pathElements <== merklePathElements;
    // merkle.pathIndices <== merklePathIndices;

    // verify that the sk matches the pkLeaf
    // we check that pkLeaf = mimc(sk) for now... should integrate eddsa sig instead once I understand them
    component mimc = MiMC7(91);
    mimc.x_in <== sk;
    mimc.k <== 1;
    pkLeaf <== mimc.out;
}


component main = MiMCSponge(2, 220, 1);