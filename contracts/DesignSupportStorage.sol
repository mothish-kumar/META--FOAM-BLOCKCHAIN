// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DesignerSupport {
    struct DataEntry {
        string encryptedHash;
        string initialVector;
        uint256 timeStamp;
    }

    mapping(bytes32 => DataEntry) private dataStore;
    bytes32[] private transactionHashes;
    address public owner;

    event DataStored(bytes32 indexed transactionHash, string encryptedHash, string initialVector, uint256 timeStamp);
    event DataUpdated(bytes32 indexed transactionHash, string newEncryptedHash, string newInitialVector, uint256 newTimeStamp);
    event DataDeleted(bytes32 indexed transactionHash);

    // Store data
    function storeData(string memory encryptedHash, string memory initialVector, uint256 timeStamp) public {
        bytes32 transactionHash = keccak256(abi.encodePacked(encryptedHash, initialVector, timeStamp, block.timestamp));
        require(dataStore[transactionHash].timeStamp == 0, "Data already exists");

        dataStore[transactionHash] = DataEntry(encryptedHash, initialVector, timeStamp);
        transactionHashes.push(transactionHash);

        emit DataStored(transactionHash, encryptedHash, initialVector, timeStamp);
    }

    // Retrieve multiple data entries
    function getAllData(uint256 startIndex, uint256 endIndex) public view returns (string[] memory, string[] memory, uint256[] memory) {
        require(endIndex < transactionHashes.length, "Invalid index range");
        require(startIndex <= endIndex, "Start index must be less than or equal to end index");

        uint256 size = endIndex - startIndex + 1;
        string[] memory encryptedHashes = new string[](size);
        string[] memory initialVectors = new string[](size);
        uint256[] memory timeStamps = new uint256[](size);

        for (uint256 i = startIndex; i <= endIndex; i++) {
            bytes32 txHash = transactionHashes[i];
            DataEntry storage entry = dataStore[txHash];
            encryptedHashes[i - startIndex] = entry.encryptedHash;
            initialVectors[i - startIndex] = entry.initialVector;
            timeStamps[i - startIndex] = entry.timeStamp;
        }

        return (encryptedHashes, initialVectors, timeStamps);
    }

    // Retrieve a single data entry
    function getSingleData(bytes32 transactionHash) public view returns (string memory, string memory, uint256) {
        require(dataStore[transactionHash].timeStamp != 0, "Data not found");
        DataEntry storage entry = dataStore[transactionHash];
        return (entry.encryptedHash, entry.initialVector, entry.timeStamp);
    }

    // Update an existing entry
    function updateData(bytes32 transactionHash, string memory newEncryptedHash, string memory newInitialVector, uint256 newTimeStamp) public {
        require(dataStore[transactionHash].timeStamp != 0, "Data not found");

        dataStore[transactionHash] = DataEntry(newEncryptedHash, newInitialVector, newTimeStamp);

        emit DataUpdated(transactionHash, newEncryptedHash, newInitialVector, newTimeStamp);
    }

    // Delete a data entry
    function deleteData(bytes32 transactionHash) public  {
        require(dataStore[transactionHash].timeStamp != 0, "Data not found");

        delete dataStore[transactionHash];

        // Remove transactionHash from the array
        for (uint256 i = 0; i < transactionHashes.length; i++) {
            if (transactionHashes[i] == transactionHash) {
                transactionHashes[i] = transactionHashes[transactionHashes.length - 1];
                transactionHashes.pop();
                break;
            }
        }

        emit DataDeleted(transactionHash);
    }

    // Get total stored data count
    function getTotalStoredData() public view returns (uint256) {
        return transactionHashes.length;
    }
}
