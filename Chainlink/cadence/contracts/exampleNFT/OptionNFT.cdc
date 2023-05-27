import FungibleToken from 0xFUNGIBLE_TOKEN_ADDRESS

pub contract NFTContract: FungibleToken.Receiver {

    // NFT structure to hold custom metadata
    pub struct NFTMetadata {
        pub var owner: Address
        pub var lister: Address
        pub var expiryTime: UInt64
        pub var premiumPrice: UFix64
        pub var strikePrice: UFix64
    }

    // NFT resource to store metadata
    resource NFT {
        pub var id: UInt64
        pub var metadata: NFTMetadata
    }

    // Collection to store NFTs
    pub let collection: Capability<&{NFT.CollectionPublic}>

    // Initialize the contract with a new empty NFT collection
    init() {
        self.collection = NFT.createEmptyCollection()
    }

    // Mint a new NFT with custom metadata
    pub fun mintNFT(
        owner: Address,
        lister: Address,
        expiryTime: UInt64,
        premiumPrice: UFix64,
        strikePrice: UFix64
    ): UInt64 {
        let newNFT <- create NFT(metadata: NFTMetadata(
            owner: owner,
            lister: lister,
            expiryTime: expiryTime,
            premiumPrice: premiumPrice,
            strikePrice: strikePrice
        ))

        let nftID = self.collection.borrow<&NFT.Collection>(from: self.collection)
            .mintNFT(token: <-newNFT)

        return nftID
    }

    // Get the custom metadata of an NFT by its ID
    pub fun getNFTMetadata(nftID: UInt64): NFTMetadata? {
        if let nft = self.collection.borrow<&NFT.Collection>(from: self.collection).borrowNFT(id: nftID) {
            return nft.metadata
        }

        return nil
    }

    // Update the custom metadata of an NFT
    pub fun updateNFTMetadata(nftID: UInt64, metadata: NFTMetadata) {
        if let nft = self.collection.borrow<&NFT.Collection>(from: self.collection).borrowNFT(id: nftID) {
            nft.metadata.owner = metadata.owner
            nft.metadata.lister = metadata.lister
            nft.metadata.expiryTime = metadata.expiryTime
            nft.metadata.premiumPrice = metadata.premiumPrice
            nft.metadata.strikePrice = metadata.strikePrice
        }
    }

    // Implementation of FungibleToken.Receiver interface

    pub fun deposit(
        _ recipient: Address,
        _ amount: UFix64,
        _ token: @FungibleToken.Vault
    ) {
        FungibleToken.deposit(from: self, to: recipient, amount: amount, token: token)
    }

    pub fun withdraw(
        _ sender: Address,
        _ amount: UFix64,
        _ token: @FungibleToken.Vault
    ) {
        FungibleToken.withdraw(from: sender, amount: amount, token: token)
    }
}
