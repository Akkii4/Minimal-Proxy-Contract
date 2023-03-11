async function main() {
  const BasicToken = await ethers.getContractFactory("BasicToken");
  const basicToken = await BasicToken.deploy();
  await basicToken.deployed();

  const BasicTokenProxyFactory = await ethers.getContractFactory(
    "BasicTokenProxyFactory"
  );
  const tok = await BasicTokenProxyFactory.deploy(basicToken.address);
  await tok.deployed();

  console.log(basicToken.address, "BasicToken base contract address");
  console.log(tok.address, "Minimal Proxy BasicToken Factory contract address");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
