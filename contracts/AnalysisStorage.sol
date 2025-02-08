// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AnalysisStorage {
    struct AnalysisData {
        string encryptedHash;
        string initialVector;
        uint256 timestamp;
        bool exists;
    }

    mapping(bytes32 => AnalysisData) private storedAnalysis;
    bytes32[] private transactionHashes;

    event AnalysisStored(bytes32 indexed transactionHash, string encryptedHash, string initialVector, uint256 timestamp);
    event AnalysisUpdated(bytes32 indexed transactionHash, string newEncryptedHash, string newInitialVector, uint256 newTimestamp);
    event AnalysisDeleted(bytes32 indexed transactionHash);

    function storeAnalysis(
        string memory _encryptedHash,
        string memory _initialVector,
        uint256 _timestamp
    ) public {
        bytes32 transactionHash = keccak256(abi.encodePacked(msg.sender, _timestamp));

        require(!storedAnalysis[transactionHash].exists, "Analysis already exists for this transaction hash");

        storedAnalysis[transactionHash] = AnalysisData(_encryptedHash, _initialVector, _timestamp, true);
        transactionHashes.push(transactionHash);

        emit AnalysisStored(transactionHash, _encryptedHash, _initialVector, _timestamp);
    }

    function getAnalysis(bytes32 _transactionHash)
        public
        view
        returns (string memory, string memory, uint256)
    {
        require(storedAnalysis[_transactionHash].exists, "Analysis not found");

        AnalysisData memory analysis = storedAnalysis[_transactionHash];
        return (analysis.encryptedHash, analysis.initialVector, analysis.timestamp);
    }

   function getAllAnalysis(uint256 startIndex, uint256 endIndex) 
    public 
    view 
    returns (bytes32[] memory, string[] memory, string[] memory, uint256[] memory) 
{
     require(startIndex < endIndex, "Invalid range");
     require(startIndex < transactionHashes.length, "Start index out of bounds");
     require(endIndex <= transactionHashes.length, "End index exceeds total product count");

    uint256 size = endIndex - startIndex;
    
    bytes32[] memory paginatedTxnHashes = new bytes32[](size);
    string[] memory encryptedHashes = new string[](size);
    string[] memory initialVectors = new string[](size);
    uint256[] memory timestamps = new uint256[](size);

    for (uint256 i = 0; i < size; i++) {
        bytes32 txnHash = transactionHashes[startIndex + i];
        AnalysisData memory data = storedAnalysis[txnHash];

        paginatedTxnHashes[i] = txnHash;
        encryptedHashes[i] = data.encryptedHash;
        initialVectors[i] = data.initialVector;
        timestamps[i] = data.timestamp;
    }

    return (paginatedTxnHashes, encryptedHashes, initialVectors, timestamps);
}


    function updateAnalysis(
        bytes32 _transactionHash,
        string memory _newEncryptedHash,
        string memory _newInitialVector,
        uint256 _newTimestamp
    ) public {
        require(storedAnalysis[_transactionHash].exists, "Analysis not found");

        storedAnalysis[_transactionHash].encryptedHash = _newEncryptedHash;
        storedAnalysis[_transactionHash].initialVector = _newInitialVector;
        storedAnalysis[_transactionHash].timestamp = _newTimestamp;

        emit AnalysisUpdated(_transactionHash, _newEncryptedHash, _newInitialVector, _newTimestamp);
    }

    function deleteAnalysis(bytes32 _transactionHash) public {
        require(storedAnalysis[_transactionHash].exists, "Analysis not found");

        delete storedAnalysis[_transactionHash];

        for (uint256 i = 0; i < transactionHashes.length; i++) {
            if (transactionHashes[i] == _transactionHash) {
                transactionHashes[i] = transactionHashes[transactionHashes.length - 1];
                transactionHashes.pop();
                break;
            }
        }

        emit AnalysisDeleted(_transactionHash);
    }

    function getTotal() public view returns (uint256) {
        return transactionHashes.length;
    }
}
