// copied from https://github.com/jbaylina/voting_example/blob/97504f4eb7f5696a964dd1595e83d0e985f900f8/circuits/mt2.circom
pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/switcher.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template MerkleVerifierLevel() {
    signal input R;
    signal input L;
    signal input selector; // selector=1 flips the two inputs
    signal output root;

    component sw = Switcher();
    sw.sel <== selector;
    sw.L <== L;
    sw.R <== R;

    // logging with a separator
    log(1111111111111);
    log(sw.outL);
    log(sw.outR);

    component hash = Poseidon(2);
    hash.inputs[0] <== sw.outL;
    hash.inputs[1] <== sw.outR;
    root <== hash.out;
}

template MerkleVerifier(nLevels) {

    // leafIndex is the index of the leaf, whose binary representation encodes the path downwards
    signal input leafIndex;
    signal input leaf;
    signal output root;
    // siblings are the siblings of the nodes in the path from the root to the leaf
    signal input siblings[nLevels];

    component n2b = Num2Bits(nLevels);
    n2b.in <== leafIndex;

    component levels[nLevels];

    for (var i=0; i<nLevels; i++) {
        levels[i] = MerkleVerifierLevel();
        levels[i].R <== siblings[i];
        if (i==0) {
            levels[i].L <== leaf;
        } else {
            levels[i].L <== levels[i-1].root;
        }
        // n2b.out[0] is the least significant bit
        levels[i].selector <== n2b.out[i];
    }

    root <== levels[nLevels-1].root;
}
