import { ethers } from "hardhat";

async function main() {
  const ElectionContract = await ethers.getContractFactory("ElectionContract");
  console.log("Deploying Election contract...");

  const election = await ElectionContract.deploy();
  await election.waitForDeployment();

  console.log("Election contract deployed to:", election.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
