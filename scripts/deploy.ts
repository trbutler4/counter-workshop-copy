import { Account, CallData, RpcProvider, constants, hash, Contract } from "starknet";
import * as dotenv from "dotenv";
import { getCompiledCode } from "./utils";
dotenv.config();

async function main() {
    const provider = new RpcProvider({
        nodeUrl: process.env.RPC_ENDPOINT,
    });

    const deployerPK = process.env.DEPLOYER_PRIVATE_KEY ?? "";
    const deployerAddress: string = process.env.DEPLOYER_ADDRESS ?? "";

    const deployerAccount = new Account(
        provider,
        deployerAddress,
        deployerPK,
    );

    let sierraCode, casmCode;

    try {
        ({ sierraCode, casmCode } = await getCompiledCode("workshop_Counter"));
    } catch (error: any) {
        console.log("Failed to read contract files");
        process.exit(1);
    }

    const myCallData = new CallData(sierraCode.abi);
    const constructorCalldata = myCallData.compile("constructor", {
        init_value: 0,
    });

    const classHash = hash.computeContractClassHash(sierraCode);

    try {
        console.log("Attempting to declare...");

        const { suggestedMaxFee: suggestedDeclareMaxFee } = await deployerAccount.estimateDeclareFee({
            contract: sierraCode,
            casm: casmCode,
        });

        await deployerAccount.declare(
            { contract: sierraCode },
            { maxFee: (suggestedDeclareMaxFee * 11n) / 10n }
        );
    } catch (error) {
        console.log('Smart contract already declared');
    }

    try {
        console.log("Attempting to deploy...");

        const { suggestedMaxFee: suggestedDeployMaxFee } = await deployerAccount.estimateDeployFee({
            classHash,
            constructorCalldata,
        });

        const deployResponse = await deployerAccount.deployContract(
            { classHash, constructorCalldata },
            { maxFee: (suggestedDeployMaxFee * 11n) / 10n }
        )

        console.log('Waiting for tx...')
        await provider.waitForTransaction(deployResponse.transaction_hash);

        const { abi } = await provider.getClassByHash(classHash);
        const deployedContract = new Contract(abi, deployResponse.contract_address, provider);

        console.log(`✅ Smart contract deployed to ${deployedContract.address}`);

    } catch (error) {
        console.log('Deployment failed');
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        process.exit(1);
    });