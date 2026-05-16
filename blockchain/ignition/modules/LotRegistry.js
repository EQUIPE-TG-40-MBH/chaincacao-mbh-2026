const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("LotRegistryModule", (m) => {
  const lotRegistry = m.contract("LotRegistry");
  return { lotRegistry };
});