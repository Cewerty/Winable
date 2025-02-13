import hre from 'hardhat';

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const TokenFactory = await hre.ethers.getContractFactory("Token", deployer);

    const initialSupply = hre.ethers.parseUnits('1000000', 18);

    const firstToken = await TokenFactory.deploy(initialSupply, "FirstToken", 18, "FT");

    firstToken.waitForDeployment();

    const firstTokenAddress = await firstToken.getAddress();

    const secondToken = await TokenFactory.deploy(initialSupply, "SecondToken", 18, "ST");

    secondToken.waitForDeployment();

    const secondTokenAddress = await secondToken.getAddress();

    const LptokenFactory = await hre.ethers.getContractFactory("LPToken", deployer);

    const LpToken = await LptokenFactory.deploy(0, "LpToken", 18, "LP");

    LpToken.waitForDeployment();

    const LpTokenAddress = await LpToken.getAddress();

    const factoryFactory = await hre.ethers.getContractFactory("Factory", deployer);

    const factory = await factoryFactory.deploy();

    factory.waitForDeployment();

    const factoryAddress = await factory.getAddress();

    const routerFactory = await hre.ethers.getContractFactory("Router");

    const router = await routerFactory.deploy(factoryAddress);

    router.waitForDeployment();

    const routerAddress = await router.getAddress();

    console.log("Token A: ", firstTokenAddress);
    console.log("Token B: ", secondTokenAddress);
    console.log("LpToken: ", LpTokenAddress);
    console.log("Factory: ", factoryAddress);
    console.log("Router: ", routerAddress);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error('Ошибка в процессе развертывания:', error);
    process.exit(1);
});