import { ethers } from "ethers";
import * as dotenv from "dotenv";
dotenv.config();
import UpdatedRentalTracking from "./ABI/UpdatedRentalTracking.json" assert { type: "json" };

// Create a contract instance
const createContractInstanceOnEthereum = (contractAddress, contractAbi) => {
  const infuraApiKey = process.env.INFURA_API_KEY; // Use environment variable for Alchemy/infura API key
  const provider = new ethers.InfuraProvider("sepolia", infuraApiKey);

  const privateKey = process.env.PRIVATE_KEY; // Use environment variable for private key
  const wallet = new ethers.Wallet(privateKey, provider);

  const contract = new ethers.Contract(contractAddress, contractAbi, wallet);
  return contract;
};

const contractAddress = "0x03694BbE3372310a86334c78Bab53A305546b4C0"; // Contract address
const contractOnEth = createContractInstanceOnEthereum(contractAddress, UpdatedRentalTracking.abi);
console.log(contractOnEth)

// Add a building
const addBuildingToContract = async (req, res) => {
    const { buildingId, buildingName, floorCount, isCommercial } = req.body;
    console.log(req.body)

    // add validation check here for checking ID of the building
    
  
    try {
      // Call the smart contract function to add the building
      const txResponse = await contractOnEth.addBuilding(buildingId, buildingName, floorCount, isCommercial);
      const txUrl = `https://sepolia.etherscan.io/tx/${txResponse.hash}`;
  
      console.log(`Building added. Transaction hash: ${txResponse.hash}`);
      res.status(200).send({
        message: "Building added successfully",
        txHash: txResponse.hash,
        txUrl,
      });
    } catch (error) {
      console.log(error, "here =>")
      // Handle specific error if building name already exists
      if (error.reason && error.reason.includes("Building name already exists")) {
        console.error("Building name already exists:", error.reason);
        res.status(400).send({
          message: "Building name already exists",
          error: error.reason,
        });
      } else {
        // Catch any other errors
        console.error("Error adding building:", error);
        res.status(500).send({
          message: "Error adding building",
          error: error.message,
        });
      }
    }
  };
  

// Add a room
const addRoomToContract = async (req, res) => {
  const { buildingId, roomId, roomRentAmount } = req.body;
  try {
    const txResponse = await contractOnEth.addRoom(buildingId, roomId, roomRentAmount);
    const txUrl = `https://sepolia.etherscan.io/tx/${txResponse.hash}`;
    console.log(`Room added. Transaction hash: ${txResponse.hash}`);
    res.status(200).send({
      message: "Room added successfully",
      txHash: txResponse.hash,
      txUrl,
    });
  } catch (error) {
    console.error("Error adding room:", error);
    res.status(500).send({ message: "Error adding room", error: error.message });
  }
};

// Rent a room
const rentRoomInContract = async (req, res) => {
  const { buildingId, roomId, tenantAddress, tenantName } = req.body;
  try {
    const txResponse = await contractOnEth.rentRoom(buildingId, roomId, tenantAddress, tenantName);
    const txUrl = `https://sepolia.etherscan.io/tx/${txResponse.hash}`;
    console.log(`Room rented. Transaction hash: ${txResponse.hash}`);
    res.status(200).send({
      message: "Room rented successfully",
      txHash: txResponse.hash,
      txUrl,
    });
  } catch (error) {
    console.error("Error renting room:", error);
    res.status(500).send({ message: "Error renting room", error: error.message });
  }
};

// Get tenant details
const getTenantDetails = async (req, res) => {
  const { buildingId, roomId } = req.body;
  try {
    const tenantDetails = await contractOnEth.getTenantDetails(buildingId, roomId);
    res.status(200).send({
      message: "Tenant details retrieved successfully",
      tenantDetails,
    });
  } catch (error) {
    console.error("Error fetching tenant details:", error);
    res.status(500).send({ message: "Error fetching tenant details", error: error.message });
  }
};

// Get room details
const getRoomDetails = async (req, res) => {
  const { buildingId, roomId } = req.body;
  try {
    const roomDetails = await contractOnEth.getRoomDetails(buildingId, roomId);
    res.status(200).send({
      message: "Room details retrieved successfully",
      roomDetails,
    });
  } catch (error) {
    console.error("Error fetching room details:", error);
    res.status(500).send({ message: "Error fetching room details", error: error.message });
  }
};

// Calculate rent for a room
const calculateRoomRent = async (req, res) => {
  const { buildingId, roomId } = req.body;
  try {
    const rent = await contractOnEth.calculateRoomRent(buildingId, roomId);
    res.status(200).send({
      message: "Room rent calculated successfully",
      rent,
    });
  } catch (error) {
    console.error("Error calculating room rent:", error);
    res.status(500).send({ message: "Error calculating room rent", error: error.message });
  }
};

// Calculate total rent for a building
const calculateTotalBuildingRent = async (req, res) => {
  const { buildingId } = req.body;
  try {
    const totalRent = await contractOnEth.calculateTotalRent(buildingId);
    res.status(200).send({
      message: "Total building rent calculated successfully",
      totalRent,
    });
  } catch (error) {
    console.error("Error calculating total building rent:", error);
    res.status(500).send({ message: "Error calculating total building rent", error: error.message });
  }
};

export {
  addBuildingToContract,
  addRoomToContract,
  rentRoomInContract,
  getTenantDetails,
  getRoomDetails,
  calculateRoomRent,
  calculateTotalBuildingRent,
};
