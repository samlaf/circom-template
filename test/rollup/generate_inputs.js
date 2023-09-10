const circomlibjs = require('circomlibjs');

async function main() {
    const mimc7 = await circomlibjs.buildMimc7();
    const hash = mimc7.hash(1, 1);
    let hashHex = Buffer.from(hash).readBigUInt64LE()
    console.log(hashHex);
}

main()