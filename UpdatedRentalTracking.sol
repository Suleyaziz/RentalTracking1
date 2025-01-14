//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./PaymentManager.sol";

contract UpdatedRentalTracking {

    struct PaymentRecord {
        bool rentPaid;
        uint256 rentAmount;
        uint256 lastUpdated;
    }

    struct Tenant {
        address tenantAddress;
        string name;
        bool exists;
    }

    struct Room {
        string roomId;
        Tenant tenant;
        PaymentRecord payment;
        uint256 roomRentAmount;
    }

    struct Building {
        string buildingName;
        uint256 floorCount;
        address owner;
        mapping(string => Room) rooms;
        bool isCommercial;
        string[] roomIds;
    }

    mapping(uint256 => Building) public buildings; // Map building ID to Building struct
    mapping(uint256 => bool) public buildingExists; // Tracks existence of building IDs
    mapping(address => uint256[]) public ownerBuildings; // Tracks buildings owned by each address
    uint256 public buildingCount = 0;

    // Event logs
    event BuildingAdded(uint256 buildingId, string buildingName, address owner);
    event RoomAdded(uint256 buildingId, string roomId);
    event RoomRented(uint256 buildingId, string roomId, address tenantAddress, string tenantName);

    // Add a new building with a unique ID and owner
    function addBuilding(
        uint256 _buildingId,
        string memory _buildingName,
        uint256 _floorCount,
        bool _isCommercial
    ) public {
        require(!buildingExists[_buildingId], "Building already exists");

        buildingExists[_buildingId] = true;
        Building storage building = buildings[_buildingId];
        building.buildingName = _buildingName;
        building.floorCount = _floorCount;
        building.isCommercial = _isCommercial;
        building.owner = msg.sender;

        ownerBuildings[msg.sender].push(_buildingId);
        buildingCount++;

        emit BuildingAdded(_buildingId, _buildingName, msg.sender);
    }

    // Add a room to a specific building
    function addRoom(
        uint256 _buildingId,
        string memory _roomId,
        uint256 _roomRentAmount
    ) public {
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        require(msg.sender == building.owner, "Only the owner can add rooms");

        require(bytes(building.rooms[_roomId].roomId).length == 0, "Room ID already exists");

        building.roomIds.push(_roomId);
        building.rooms[_roomId] = Room(
            _roomId,
            Tenant(address(0), "", false),
            PaymentRecord(false, 0, block.timestamp),
            _roomRentAmount
        );

        emit RoomAdded(_buildingId, _roomId);
    }

    // Tenant rents a room
    function rentRoom(uint256 _buildingId, string memory _roomId, address _tenantAddress, string memory _tenantName) public {
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        Room storage room = building.rooms[_roomId];
        require(bytes(room.roomId).length != 0, "Room does not exist");
        require(!room.tenant.exists, "Room is already occupied");

        room.tenant = Tenant(_tenantAddress, _tenantName, true);

        emit RoomRented(_buildingId, _roomId, _tenantAddress, _tenantName);
    }

    // Get tenant details for a specific room
    function getTenantDetails(uint256 _buildingId, string memory _roomId) public view returns (address, string memory) {
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        Room storage room = building.rooms[_roomId];
        require(bytes(room.roomId).length != 0, "Room does not exist");
        require(room.tenant.exists, "Room is vacant");

        return (room.tenant.tenantAddress, room.tenant.name);
    }

    // Get room details (occupied or vacant)
    function getRoomDetails(uint256 _buildingId, string memory _roomId) public view returns (
            string memory,
            uint256,
            bool,
            address,
            string memory
        )
        
    {
       
       
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        Room storage room = building.rooms[_roomId];
        require(bytes(room.roomId).length != 0, "Room does not exist");

        if (room.tenant.exists) {
            return (
                room.roomId,
                room.roomRentAmount,
                true,
                room.tenant.tenantAddress,
                room.tenant.name
            );
        } else {
            return (
                room.roomId,
                room.roomRentAmount,
                false,
                address(0),
                "Vacant"
            );
        }
    }

    // TODO: get building details and total rooms in building
    function getBuildingDetails(uint256 _buildingId ) public view returns (string memory, uint256, address, uint256) {

             require(buildingExists[_buildingId], "Building does not exist");
             Building storage building = buildings[_buildingId];
             uint256 totalRooms = building.roomIds.length;
             return(building.buildingName,
             building.floorCount,
             building.owner,
             totalRooms);
          

    }
     
     // make a seperate contract for making payment then import to the updatedrentaltracking.sol
     //make a getAllTenants in a building function 

    // Calculate rent for one room
    function calculateRoomRent(uint256 _buildingId, string memory _roomId) public view returns (uint256) {
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        Room storage room = building.rooms[_roomId];
        require(bytes(room.roomId).length != 0, "Room does not exist");

        return room.roomRentAmount;
    }
    //create a billTenant function includes total room rent, pay rent function
    // fro the params: the tenant(address) and room ID abuilding ID 

    // Calculate total rent for a building
    function calculateTotalRent(uint256 _buildingId) public view returns (uint256) {
        require(buildingExists[_buildingId], "Building does not exist");
        Building storage building = buildings[_buildingId];
        uint256 totalRent = 0;

        for (uint256 i = 0; i < building.roomIds.length; i++) {
            string memory roomId = building.roomIds[i];
            totalRent += building.rooms[roomId].roomRentAmount;
        }

        return totalRent;
    }
}
