const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const buildMimc7 = require("circomlibjs").buildMimc7;

describe("MiMC Circuit test", function () {
    let circuit;
    let mimc7;

    this.timeout(100000);

    before(async () => {
        mimc7 = await buildMimc7();
        circuit = await wasm_tester(path.join(__dirname, "..", "circuits", "rollup.circom"));
    });

    it("Should check constrain", async () => {
        const sk = 1;
        const k = 1;
        const w = await circuit.calculateWitness({ sk: sk }, true);

        const res2 = mimc7.hash(sk, k);

        await circuit.assertOut(w, { pkLeaf: mimc7.F.toObject(res2) });

        await circuit.checkConstraints(w);
    });
});
