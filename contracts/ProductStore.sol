pragma solidity ^0.8.0;

contract ProductStorage {
    // Struct to store encrypted product data
    struct Product {
        uint256 productId;      // Unique product ID
        string encryptedHash;   // The encrypted hash of the product data
        string initialVector;   // The initial vector (IV) used in encryption
        uint256 timestamp;      // Timestamp of when the data was stored
    }

    // Counter for generating unique product IDs
    uint256 private nextProductId = 1;
    
    // Mapping to store product data by product ID
    mapping(uint256 => Product) public productsById;
    
    // Mapping to store product data by encrypted hash (for backward compatibility)
    mapping(string => uint256) private hashToId;
    
    // Array to store all product IDs for iteration
    uint256[] public productIds;
   
    // Counter to keep track of the number of products
    uint256 public productCount;

    // Function to get the number of products
    function getProductCount() public view returns (uint256) {
        return productCount;
    }

    // Function to store encrypted product data
    function storeProduct(
        string memory encryptedHash,
        string memory initialVector,
        uint256 timestamp
    ) public returns (uint256) {
        require(hashToId[encryptedHash] == 0, "Product already exists");
        
        uint256 productId = nextProductId++;
        productsById[productId] = Product(productId, encryptedHash, initialVector, timestamp);
        hashToId[encryptedHash] = productId;
        productIds.push(productId);
        productCount++;
        
        return productId;
    }

    // Store multiple products at once (Batch Insert)
    function storeMultipleProducts(
        string[] memory encryptedHashes,
        string[] memory initialVectors,
        uint256[] memory timestamps
    ) public returns (uint256[] memory) {
        require(
            encryptedHashes.length == initialVectors.length && 
            initialVectors.length == timestamps.length,
            "Array lengths must match"
        );

        uint256[] memory newProductIds = new uint256[](encryptedHashes.length);
        
        for (uint256 i = 0; i < encryptedHashes.length; i++) {
            if (hashToId[encryptedHashes[i]] == 0) {
                uint256 productId = nextProductId++;
                productsById[productId] = Product(
                    productId,
                    encryptedHashes[i],
                    initialVectors[i],
                    timestamps[i]
                );
                hashToId[encryptedHashes[i]] = productId;
                productIds.push(productId);
                productCount++;
                newProductIds[i] = productId;
            }
        }
        
        return newProductIds;
    }

    // Function to get all product records in a range
    function getAllProducts(uint256 startIndex, uint256 endIndex)
        public
        view
        returns (
            uint256[] memory ids,
            string[] memory encryptedHashes,
            string[] memory initialVectors,
            uint256[] memory timestamps
        )
    {
        require(startIndex < endIndex, "Invalid range");
        require(startIndex < productIds.length, "Start index out of bounds");
        require(endIndex <= productIds.length, "End index exceeds total product count");

        uint256 size = endIndex - startIndex;
        ids = new uint256[](size);
        encryptedHashes = new string[](size);
        initialVectors = new string[](size);
        timestamps = new uint256[](size);
        
        for (uint256 i = 0; i < size; i++) {
            uint256 productId = productIds[startIndex + i];
            Product memory product = productsById[productId];
            ids[i] = product.productId;
            encryptedHashes[i] = product.encryptedHash;
            initialVectors[i] = product.initialVector;
            timestamps[i] = product.timestamp;
        }

        return (ids, encryptedHashes, initialVectors, timestamps);
    }

    // Function to get a product by ID
    function getProductById(uint256 productId)
        public
        view
        returns (Product memory)
    {
        require(productsById[productId].productId != 0, "Product not found");
        return productsById[productId];
    }

    // Function to delete a product by ID
    function deleteProduct(uint256 productId) public {
        require(productsById[productId].productId != 0, "Product not found");
        
        // Remove from hashToId mapping
        string memory hash = productsById[productId].encryptedHash;
        delete hashToId[hash];
        
        // Remove from productsById mapping
        delete productsById[productId];

        // Remove from productIds array
        for (uint256 i = 0; i < productIds.length; i++) {
            if (productIds[i] == productId) {
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }

        if (productCount > 0) {
            productCount--;
        }
    }

    //Function to delete all products
    function deleteAllProducts() public {
        // Delete all products from mappings
        for(uint256 i = 0; i < productIds.length; i++) {
            uint256 productId = productIds[i];
            string memory hash = productsById[productId].encryptedHash;
            delete hashToId[hash];
            delete productsById[productId];
        }
        
        // Clear the productIds array
        while(productIds.length > 0) {
            productIds.pop();
        }
        
        // Reset counters
        productCount = 0;
        nextProductId = 1;
    }

    // Function to update specific product fields
    function updateProduct(
        uint256 productId,
        string memory encryptedHash,
        string memory initialVector,
        uint256 timestamp
    ) public returns (bool) {
        require(productsById[productId].productId != 0, "Product not found");
        
        // Remove old hash mapping
        string memory oldHash = productsById[productId].encryptedHash;
        delete hashToId[oldHash];
        
        // Update product
        productsById[productId] = Product(
            productId,
            encryptedHash,
            initialVector,
            timestamp
        );
        
        // Update hash mapping
        hashToId[encryptedHash] = productId;
        
        return true;
    }
}
