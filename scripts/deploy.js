const hre = require("hardhat");

async function main() {
	// Deploying GlimToken Contract
	const GlimToken = await hre.ethers.getContractFactory("GLDToken");
	const glimToken = await GlimToken.deploy();
	await glimToken.deployed();
	console.log(`GlimToken deployed to: ${glimToken.address}`);

	// Deploying GlimMinter Contract
	const GlimMinter = await hre.ethers.getContractFactory("GlimMinter");
	const glimMinter = await GlimMinter.deploy(glimToken.address);
	await glimMinter.deployed();
	console.log(`GlimMinter deployed to: ${glimMinter.address}`);

	// Set the minter to be the GlimMinter contract
	await glimToken.setMinter(glimMinter.address);
	console.log(`Minter for GlimToken set to: ${glimMinter.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
