# Property Smart Contract

This is a Solidity smart contract for managing property transactions, including buying, leasing, and transferring properties. The contract includes features such as setting commissions, system prices, and handling property leases.

## Smart Contract Overview

### Constants
- `contract-owner`: The address of the contract owner, initialized as `msg.sender`.
- `commission`: A constant representing the commission rate, between 1-5.

### Variables
- `system-price`: The default price for property transactions, initialized to 100.
- `last-token-id`: The last property NFT (Non-Fungible Token) ID, initialized to 0.

### Functions
1. `setCommision(uint)`: Set the commission rate, only callable by the contract owner.
2. `getCommision()`: Get the current commission rate.
3. `setSystemPrice(uint)`: Set the system price, only callable by the contract owner.
4. `getSystemPrice()`: Get the current system price.
5. `getPropertyPrice(uint)`: Get the price for a particular property.
6. `getPropertyLeasePrice(uint)`: Get the lease price for a particular property.
7. `buy(address)`: Buy a property, transferring the required funds to the contract and updating maps and variables.
8. `giveLease(uint, address, uint, uint)`: Give a lease for a property to another address, updating maps.
9. `claimLease(uint)`: Claim a leased property, transferring funds and updating maps.
10. `completeLease(uint)`: Complete a lease, transferring the property back to the owner after the lease period.
11. `cancelLease(uint256)`: Cancel a lease, transferring the property back to the owner if not paid.
12. `getLastTokenId()`: Get the last property NFT ID.
13. `getOwner(uint)`: Get the owner of a given property NFT.
14. `transfer(uint, address)`: Transfer a property to another address if not on lease.

## Usage

1. Deploy the contract to the Ethereum blockchain.
2. Interact with the contract using the defined functions through a decentralized application (DApp) or command-line interface.

## Important Notes

- Ensure that the contract owner sets appropriate commission rates and system prices.
- Follow the specified conditions for leasing, claiming, completing, and canceling leases.
- Verify the ownership and status of properties before transferring.

## License

This smart contract is open-source and available under the [GPLv3](LICENSE).
