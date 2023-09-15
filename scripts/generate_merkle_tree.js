const { buildPoseidon, } = require("circomlibjs");


// use this script to generate the merkle tree values
// and then copy them into inputs/<CIRCUIT>.json 
async function main() {
    const poseidon = await buildPoseidon();

    // Change these leaves
    var leaves = [1, 2, 3, 4];
    console.log("leaves values", leaves);
    for (let i = 0; i < leaves.length; i++) {
        leaves[i] = poseidon([poseidon.F.e(leaves[i])])
    }
    console.log("hashed leaves", leaves.map(x => poseidon.F.toString(x)));

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
