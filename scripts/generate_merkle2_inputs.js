const { type } = require("os");
const path = require("path");
const { buildPoseidon, } = require("circomlibjs");
const { utils } = require("ffjavascript");

async function main() {
    const poseidon = await buildPoseidon();

    var leaves = [1, 2, 3, 4];
    console.log("leaves values", leaves);
    for (let i=0; i<leaves.length; i++) {
        leaves[i] = poseidon([poseidon.F.e(leaves[i])])
    }
    console.log("hashed leaves", leaves.map(x => poseidon.F.toString(x)));
    const k = 1;

    while (leaves.length > 1) {
        left = leaves[0];
        right = leaves[1]
        hash = poseidon([left, right]);
        console.log(`poseidon(${poseidon.F.toString(left)}, ${poseidon.F.toString(right)}) = ${poseidon.F.toString(hash)}`)
        // remove the two leaves and replace them with their hash
        leaves = leaves.slice(2).concat([hash])
    }


};

main()
