pragma circom 2.0.0;

include "./merkle.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

// For now we prove that we know a secret which is the Poseidon preimage of a leaf in a merkle tree
// secret --> leaf1 --> node1 \
//            leaf2 /          --> root
//            leaf3 --> node2 /
//            leaf4 /
template Rollup() {
    var levels = 2; // depth of merkle tree
    signal input secret;
    signal input merkleLeafIndex; //index in merkle leaf (0 - 2^n-1)
    signal output merkleRoot;
    signal input merklePathElements[levels];
    
    // hash the secret to get the leaf value (we assume leaf = poseidon(secret) for now...)
    // should integrate eddsa sig instead once I understand them
    component poseidon1 = Poseidon(1);
    poseidon1.inputs[0] <== secret;

    // verify that the pubkeyLeaf passed as input is in the merkle tree
    component merkle = MerkleVerifier(levels);
    merkle.leaf <== poseidon1.out;
    merkle.siblings <== merklePathElements;
    merkle.leafIndex <== merkleLeafIndex;

    merkleRoot <== merkle.root;
}


component main = Rollup();