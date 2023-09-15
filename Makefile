-include Makefile.overrides
############################# HELP MESSAGE #############################
# Make sure the help command stays first, so that it's printed by default when `make` is called without arguments
.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

potPower = 12
phase1_ptau_file0 = powersoftau_phase1/phase1_pow${potPower}_0.ptau
phase1_ptau_file1 = powersoftau_phase1/phase1_pow${potPower}_1.ptau
phase1_ptau_beacon_file = powersoftau_phase1/phase1_pow${potPower}.beacon.ptau

circuit_name = merkle2

# variables derived from circuit_name
circom_file = circuits/${circuit_name}.circom
generated_files_dir = generated/${circuit_name}
phase2_ptau_file = ${generated_files_dir}/phase2_pow${potPower}.ptau
r1cs_file = ${generated_files_dir}/${circuit_name}.r1cs
zkey_file = ${generated_files_dir}/${circuit_name}.zkey
vkey_file = ${generated_files_dir}/${circuit_name}.vkey.json
wasm_file = ${generated_files_dir}/${circuit_name}_js/${circuit_name}.wasm
input_file = inputs/${circuit_name}.json
witness_file = ${generated_files_dir}/${circuit_name}.wtns
proof_file = ${generated_files_dir}/${circuit_name}.proof.json
public_input_file = ${generated_files_dir}/${circuit_name}.public.json

powersoftau-phase1: ## only needs to be run once per potPower
	@echo "Generating powers of tau for bn254 up to power ${potPower}, with 2 contributions"
	snarkjs powersoftau new bn254 ${potPower} ${phase1_ptau_file0}
	snarkjs powersoftau contribute ${phase1_ptau_file0} ${phase1_ptau_file1} --name="Second contribution"
	snarkjs powersoftau beacon ${phase1_ptau_file1} ${phase1_ptau_beacon_file} 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

compile-circuit: ## compile to r1cs, prepare pot phase2, and generate zkey and vkey
	mkdir -p ${generated_files_dir}
	snarkjs powersoftau prepare phase2 ${phase1_ptau_beacon_file} ${phase2_ptau_file}
	circom --r1cs --wasm --sym ${circom_file} -o ${generated_files_dir}
	snarkjs groth16 setup ${r1cs_file} ${phase2_ptau_file} ${zkey_file}
	snarkjs zkey export verificationkey ${zkey_file} ${vkey_file}

# Make sure to create and fill input.json file first, and to have compiled the circuit
prove: ## calculate the witness given the input, and generate the proof
	snarkjs wtns calculate ${wasm_file} ${input_file} ${witness_file}
	snarkjs groth16 prove ${zkey_file} ${witness_file} ${proof_file} ${public_input_file}

verify-proof: ## 
	snarkjs groth16 verify ${vkey_file} ${public_input_file} ${proof_file}


print-circuit: ## 
	snarkjs r1cs export json
	code circuit.json

print-witness: ## 
	snarkjs wtns export json
	code witness.json

# Getting some wasm error: https://github.com/iden3/circomlib/issues/103
test: ## 
	mocha

clean: ## 
	rm -rf generated/*