const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("feeTokenTest", () => {
  beforeEach(async () => {
    [owner, wallet, addr1, addr2] = await ethers.getSigners();
    const feeTokenInstance = await ethers.getContractFactory("FeeToken");
    feeToken = await feeTokenInstance.deploy('ABC', 'ABC');
  });
    it("should transfer", async () => {
      await feeToken._setWallet(wallet.address);
      await feeToken.transfer(addr1.address, 100000);
      await feeToken.connect(addr1).transfer(addr2.address, 10000);

      const endingWalletBalance = await feeToken.balanceOf(wallet.address);
      const endingSenderBalance = await feeToken.balanceOf(addr1.address);
      const endingRecipientBalance = await feeToken.balanceOf(addr2.address);

      expect(275).to.equal(endingWalletBalance);
      expect(79750).to.equal(endingSenderBalance);
      expect(9975).to.equal(endingRecipientBalance);
    });

    it("should set a new fee", async () => {
      const newTaxFee = 50;

      await feeToken._setFee(newTaxFee);

      const endingTaxFee = await feeToken.taxFee();

      expect(newTaxFee).to.equal(endingTaxFee);
    });

    it("should set a new wallet", async () => {
      await feeToken._setWallet(wallet.address);
  
      const endingWallet = await feeToken.wallet();
  
      expect(wallet.address).to.equal(endingWallet);
    });
});