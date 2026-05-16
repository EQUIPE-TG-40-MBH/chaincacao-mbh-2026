// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LotRegistry
 * @dev Contrat pour la traçabilité du cacao (Projet CHAINCACAO)
 * Inclut la gestion des accès, l'historique immuable et le merging EUDR.
 */
contract LotRegistry {
    address public owner;

    struct Lot {
        string lotId;
        string farmerId;
        string cooperativeId;
        uint256 weightDeclared;
        uint256 weightVerified;
        string gpsCoordinates; // Preuve de non-déforestation
        string cultureType;
        uint256 registeredAt;
        string status;
        address registeredBy;
        string parentLotIds; // Pour le mélange des lots (Merging)
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

    // Événements indexés pour que le Backend de Jacques soit ultra-rapide
    event LotRegistered(string indexed lotId, string indexed farmerId, uint256 timestamp);
    event LotTransferred(string indexed lotId, string fromActor, string toActor, uint256 timestamp);
    event LotStatusUpdated(string indexed lotId, string newStatus, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul l'admin peut faire ca");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Enregistrement initial d'un lot par un producteur/coopérative
    function registerLot(
        string memory _lotId,
        string memory _farmerId,
        string memory _cooperativeId,
        uint256 _weightDeclared,
        string memory _gpsCoordinates,
        string memory _cultureType
    ) public {
        require(bytes(lots[_lotId].lotId).length == 0, "Lot existe deja");

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
            registeredBy: msg.sender,
            parentLotIds: ""
        });

        allLotIds.push(_lotId);
        emit LotRegistered(_lotId, _farmerId, block.timestamp);
    }

    // Transfert de lot avec vérification de poids (crucial pour la chaine de valeur)
    function transferLot(
        string memory _lotId,
        string memory _fromActor,
        string memory _toActor,
        uint256 _weightVerified,
        string memory _notes
    ) public {
        require(bytes(lots[_lotId].lotId).length > 0, "Lot inexistant");

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

    // Spécial Hackathon : Fonction de mélange de lots (Merging) pour l'export
    function mergeLots(
        string memory _newLotId, 
        string memory _parentLotIds, 
        uint256 _totalWeight
    ) public onlyOwner {
        registerLot(_newLotId, "MULTIPLE", "COOPERATIVE_MERGE", _totalWeight, "VERIFIED_AREA", "COCOA_MERGED");
        lots[_newLotId].parentLotIds = _parentLotIds;
        lots[_newLotId].status = "MERGED_READY_FOR_EXPORT";
    }

    function updateStatus(string memory _lotId, string memory _newStatus) public {
        require(bytes(lots[_lotId].lotId).length > 0, "Lot inexistant");
        lots[_lotId].status = _newStatus;
        emit LotStatusUpdated(_lotId, _newStatus, block.timestamp);
    }

    // Fonctions de lecture
    function getLot(string memory _lotId) public view returns (Lot memory) {
        return lots[_lotId];
    }

    function getLotHistory(string memory _lotId) public view returns (Transfer[] memory) {
        return lotTransfers[_lotId];
    }

    function getTotalLots() public view returns (uint256) {
        return allLotIds.length;
    }
}