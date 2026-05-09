// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotRegistry {

    struct Lot {
        string lotId;
        string farmerId;
        string cooperativeId;
        uint256 weightDeclared;
        uint256 weightVerified;
        string gpsCoordinates;
        string cultureType;
        uint256 registeredAt;
        string status;
        address registeredBy;
    }

    struct Transfer {
        string lotId;
        string fromActor;
        string toActor;
        uint256 transferredAt;
        string notes;
    }

    mapping(string => Lot) public lots;
    mapping(string => Transfer[]) public lotTransfers;
    string[] public allLotIds;

    event LotRegistered(string lotId, string farmerId, uint256 timestamp);
    event LotTransferred(string lotId, string fromActor, string toActor, uint256 timestamp);
    event LotStatusUpdated(string lotId, string newStatus, uint256 timestamp);

    function registerLot(
        string memory _lotId,
        string memory _farmerId,
        string memory _cooperativeId,
        uint256 _weightDeclared,
        string memory _gpsCoordinates,
        string memory _cultureType
    ) public {
        require(bytes(lots[_lotId].lotId).length == 0, "Lot already exists");

        lots[_lotId] = Lot({
            lotId: _lotId,
            farmerId: _farmerId,
            cooperativeId: _cooperativeId,
            weightDeclared: _weightDeclared,
            weightVerified: 0,
            gpsCoordinates: _gpsCoordinates,
            cultureType: _cultureType,
            registeredAt: block.timestamp,
            status: "REGISTERED",
            registeredBy: msg.sender
        });

        allLotIds.push(_lotId);
        emit LotRegistered(_lotId, _farmerId, block.timestamp);
    }

    function transferLot(
        string memory _lotId,
        string memory _fromActor,
        string memory _toActor,
        uint256 _weightVerified,
        string memory _notes
    ) public {
        require(bytes(lots[_lotId].lotId).length > 0, "Lot does not exist");

        if (_weightVerified > 0) {
            lots[_lotId].weightVerified = _weightVerified;
        }

        lots[_lotId].status = "IN_TRANSFER";

        lotTransfers[_lotId].push(Transfer({
            lotId: _lotId,
            fromActor: _fromActor,
            toActor: _toActor,
            transferredAt: block.timestamp,
            notes: _notes
        }));

        emit LotTransferred(_lotId, _fromActor, _toActor, block.timestamp);
    }

    function updateStatus(
        string memory _lotId,
        string memory _newStatus
    ) public {
        require(bytes(lots[_lotId].lotId).length > 0, "Lot does not exist");
        lots[_lotId].status = _newStatus;
        emit LotStatusUpdated(_lotId, _newStatus, block.timestamp);
    }

    function getLot(string memory _lotId) public view returns (Lot memory) {
        require(bytes(lots[_lotId].lotId).length > 0, "Lot does not exist");
        return lots[_lotId];
    }

    function getLotHistory(string memory _lotId) public view returns (Transfer[] memory) {
        return lotTransfers[_lotId];
    }

    function getTotalLots() public view returns (uint256) {
        return allLotIds.length;
    }
}