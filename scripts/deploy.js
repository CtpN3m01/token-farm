import hre from "hardhat";

async function main() {
  console.log("🚀 Starting deployment...");
  
  // Deploy DAppToken
  console.log("\n📄 Deploying DAppToken...");
  const dappToken = await hre.viem.deployContract("DAppToken", [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" // Default hardhat account #0
  ]);
  console.log("✅ DAppToken deployed to:", dappToken.address);

  // Deploy LPToken
  console.log("\n📄 Deploying LPToken...");
  const lpToken = await hre.viem.deployContract("LPToken", [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" // Default hardhat account #0
  ]);
  console.log("✅ LPToken deployed to:", lpToken.address);

  // Deploy TokenFarm
  console.log("\n📄 Deploying TokenFarm...");
  const tokenFarm = await hre.viem.deployContract("TokenFarm", [
    dappToken.address,
    lpToken.address
  ]);
  console.log("✅ TokenFarm deployed to:", tokenFarm.address);

  // Transfer ownership of DAppToken to TokenFarm
  console.log("\n🔄 Transferring DAppToken ownership to TokenFarm...");
  await dappToken.write.transferOwnership([tokenFarm.address]);
  console.log("✅ Ownership transferred successfully");

  console.log("\n🎉 DEPLOYMENT COMPLETE!");
  console.log("=" .repeat(50));
  console.log("📊 Contract Addresses:");
  console.log("DApp Token :", dappToken.address);
  console.log("LP Token   :", lpToken.address);
  console.log("Token Farm :", tokenFarm.address);
  console.log("=" .repeat(50));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });