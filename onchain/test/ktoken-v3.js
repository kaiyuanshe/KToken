const { expect } = require("chai");

describe("KToken V3 contract", function () {
  it("Token transfer test", async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    const hardhatToken = await ethers.deployContract("KTokenV3");
    console.log("Token address:", await hardhatToken.getAddress());

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    console.log("Owner balance checked");

    await hardhatToken.transfer(user1.address, 10)
    expect(await hardhatToken.balanceOf(user1.address)).to.equal(10);
    console.log("Token granting checked");

    expect(await hardhatToken.connect(user1.address).transferFrom(user1.address, user2.address, 1)).to.be.revertedWith("Token transfer disabled!");
    console.log("Transfer disable checked");
  });
});