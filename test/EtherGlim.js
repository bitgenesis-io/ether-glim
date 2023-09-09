const GlimToken = artifacts.require("GlimToken");
const GlimMinter = artifacts.require("GlimMinter");

contract("GlimToken and GlimMinter", (accounts) => {
	const owner = accounts[0];
	const minter = accounts[1];
	const user = accounts[2];
	const attacker = accounts[3];
	let glimToken;
	let glimMinter;

	// Initialization
	describe("Initialization", () => {
		beforeEach(async () => {
			glimToken = await GlimToken.new({ from: owner });
			glimMinter = await GlimMinter.new(glimToken.address, { from: owner });
		});

		it("should initialize GlimToken with the correct values", async () => {
			const name = await glimToken.name();
			const symbol = await glimToken.symbol();
			assert.equal(name, "Glim");
			assert.equal(symbol, "GLM");
		});

		it("should set GlimMinter as minter for GlimToken", async () => {
			await glimToken.setMinter(glimMinter.address, { from: owner });
			const actualMinter = await glimToken.minter();
			assert.equal(actualMinter, glimMinter.address);
		});
	});

	// Ownership and Minter
	describe("Ownership and Minter", () => {
		beforeEach(async () => {
			glimToken = await GlimToken.new({ from: owner });
			glimMinter = await GlimMinter.new(glimToken.address, { from: owner });
		});

		it("should allow owner to set minter", async () => {
			await glimToken.setMinter(minter, { from: owner });
			const actualMinter = await glimToken.minter();
			assert.equal(actualMinter, minter);
		});

		it("should not allow non-owner to set minter", async () => {
			try {
				await glimToken.setMinter(minter, { from: attacker });
				assert.fail("Expected revert not received");
			} catch (error) {
				assert.include(error.message, "revert");
			}
		});
	});

	// GlimMinter Price Updates and Claims
	describe("GlimMinter Price Updates and Claims", () => {
		beforeEach(async () => {
			glimToken = await GlimToken.new({ from: owner });
			glimMinter = await GlimMinter.new(glimToken.address, { from: owner });
		});

		it("should allow owner to update price", async () => {
			const newPrice = web3.utils.toWei("0.1", "ether");
			await glimMinter.updatePrice(10, newPrice, { from: owner });
			const updatedPrice = await glimMinter.priceForAmount(10);
			assert.equal(updatedPrice.toString(), newPrice);
		});

		it("should not allow non-owner to update price", async () => {
			try {
				await glimMinter.updatePrice(10, web3.utils.toWei("0.1", "ether"), {
					from: attacker,
				});
				assert.fail("Expected revert not received");
			} catch (error) {
				assert.include(error.message, "revert");
			}
		});

		it("should allow users to claim tokens", async () => {
			const claimAmount = 10;
			const claimPrice = await glimMinter.priceForAmount(claimAmount);
			await glimMinter.claimTokens(claimAmount, {
				from: user,
				value: claimPrice,
			});
			const userBalance = await glimToken.balanceOf(user);
			assert.equal(userBalance.toString(), claimAmount.toString());
		});
	});

	// More scenarios should be added here to cover all aspects of both contracts.
});
