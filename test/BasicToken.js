const { expect } = require("chai");

const getGas = async (tx) => {
  const receipt = await ethers.provider.getTransactionReceipt(tx.hash);
  return receipt.gasUsed.toString();
};

describe("BasicToken + BasicTokenFactory", function () {
  it("Should deploy the base contract and storage contract + gas savings", async function () {
    const BasicToken = await ethers.getContractFactory("BasicToken");
    const basicToken = await BasicToken.deploy();
    await basicToken.deployed();

    let basicTokenStandaloneGas = await getGas(basicToken.deployTransaction);

    expect(basicToken.address).to.exist;

    const BasicTokenFactory = await ethers.getContractFactory(
      "BasicTokenProxyFactory"
    );
    const tok = await BasicTokenFactory.deploy(basicToken.address);
    await tok.deployed();

    expect(tok.address).to.exist;

    const tx = await tok.createNewToken("Dummy Token", "DUM");

    let basicTokenFactoryGas = await getGas(tx);
    console.log(
      "Gas cost of deploying the implementation contract alone: " +
        basicTokenStandaloneGas
    );
    console.log(
      "Gas cost of deploying a new basicToken via creating a clone: ",
      basicTokenFactoryGas
    );
    console.log(
      "Gas Cost savings : ",
      (100 - (basicTokenFactoryGas / basicTokenStandaloneGas) * 100).toFixed(2),
      "%"
    );
  });
});
