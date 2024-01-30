// constants
// contract-owner : address , msg.sender
// commision: uint , between 1-5

// variables
// system-price : uint , default to 100
// last-token-id : uint , default to 0

// maps
// property (key: uint) (value: {price: uint, commision: uint})
// lease (key: uint) (value: {owner : address, timestamp: uint , price: uint, isPaid: bool})

interface IProperty {

    // price
    function setCommision(uint) external;
    // only contract-owner can set the commision
    // value must be >= 1 and <= 5

    // returns the contract-owner commision
    function getCommision() external view returns (uint);

    function setSystemPrice(uint) external;
    // only contract-owner can set the system price
    // value must be >= 100 and <= 1000

    // returns the system price
    function getSystemPrice() external view returns (uint);

    //  returns the price for a particular property
    function getPropertyPrice(uint) external view returns (uint);

    // id
    function getPropertyLeasePrice(uint) external view returns (uint);
    // returns the lease price for a particular property


    // contract-caller pays x eth to contract / address(this), where x = getSystemPrice()
    // contract-caller pays x commision to the contract owner, where x = getCommision()
    // property nft is bought for address supplied
    // update maps, variables
    function buy(address) external payable;

    // id, lessee, timestamp, price
    function giveLease(uint, address, uint, uint) external;
    // ensure timestamp is a future time
    // ensure price is > 0
    // nft owner transfers property nft to the contract/escrow/address(this) for the timestamp and price supplied 
    // update maps

    function claimLease(uint) external payable;
    // lessee transfers eth based on the lease price to the contract/escrow/address(this)
    // contract/escrow/address(this) transfers the payment to the owner and the nft to the lessee
    // update maps

    function completeLease(uint) external;
    // check if contract-caller is original owner
    // check if current time >= lease time
    // transfer nft from leasee back to owner
    // update maps

    // ID
    function cancelLease(uint256) external;
    // if lease is paid then deny
    // if contract-caller is not owner then deny
    // contract/escrow transfers nft back to contract-caller
    // update maps

    function getLastTokenId() external view returns (uint);
    // returns the last property nft id bought/minted

    function getOwner(uint) external view returns (address);
    // Owner of a given token identifier

    // id, reciever
    function transfer(uint, address) external;
    // if property is on lease then deny
    // if contract-caller is not owner deny
    // transfer nft from contract-caller to reciever
    // update maps
}

contract Property is IProperty{
    address immutable private contractOwner; // contract-owner : address , msg.sender
    uint immutable Commission; // commision: uint , between 1-5
    uint private systemPrice;
    uint private lastTokenId;

    struct property{
        uint price;
        uint commission;
    }

    struct lease{
        address owner;
        uint timestamp;
        uint price;
        bool isPaid;
    }
    mapping (uint => property) propertyMap;
    mapping (uint => lease) leaseMap;

    constructor(){
        contractOwner=msg.sender;
        systemPrice=100;
        lastTokenId=0;
    }

    // price
    function setCommision(uint c) external{
        require(msg.sender==contractOwner,"Only contract owner can set commission");
        require(c>=1 && c<=5, "Commision value must be  >= 1 and <= 5");
        Commission=c;
    }
    
    // returns the contract-owner commision
    function getCommision() external view returns (uint){
        return Commission;
    }


     function setSystemPrice(uint p) external{
        require(msg.sender==contractOwner,"Only contract owner can set system price");
        require(p>=100 && p<=1000,"System price value must be >= 100 and <= 1000");
        systemPrice=p;
     }

    // returns the system price
    function getSystemPrice() external view returns (uint){
        return systemPrice;
    }

    //  returns the price for a particular property
    function getPropertyPrice(uint p) external view returns (uint){
        require(p<lastTokenId,"Property does not exist");
        return propertyMap[p].price;
    }

    // id
    function getPropertyLeasePrice(uint p) external view returns (uint){
        require(p<lastTokenId,"Lease does not exist");
        return leaseMap[p].price;
    }


    // contract-caller pays x eth to contract / address(this), where x = getSystemPrice()
    // contract-caller pays x commision to the contract owner, where x = getCommision()
    // property nft is bought for address supplied
    // update maps, variables
    function buy(address a) external payable{
        uint sysPrice=this.getSystemPrice();
        uint commis=this.getCommision();
        payable(address(this)).transfer(sysPrice);
        payable(contractOwner).transfer(commis);
        Property newProp=({price: sysPrice , commission: commis});
        propertyMap[lastTokenId]=newProp;
        lastTokenId++;
        a.transfer(newProp);
    }

    // id, lessee, timestamp, price
    function giveLease(uint id, address a, uint ts, uint p) external{
        require(ts>block.timestamp,"Lease time must be a future time");
        require(p>0,"Price of lease must be >0");
        lease memory newLease=lease(msg.sender,ts,p,false);
        leaseMap[id]=newLease;
        a.transfer(newLease);
    }

    function claimLease(uint id) external payable{
        int p=leaseMap[id].price;
        leaseMap[id].owner.transfer(p);
        leaseMap[id].isPaid=true;
        msg.sender.transfer(propertyMap[id]);
    }

    function completeLease(uint id) external{
        require(msg.sender==contractOwner,"Only owner can complete lease");
        require(block.timestamp >= leaseMap[id].timestamp, "Current time must be >= lease time stamp");
        leaseMap[id].owner.transfer(propertyMap[id]);
    }

    // ID
    function cancelLease(uint256 id) external{
        require(leaseMap[id].isPaid==false,"Payment done, cannot cancel lease");
        require(msg.sender==leaseMap[id].owner,"Only lease owner can cancel the lease");
        msg.sender.transfer(leaseMap[id]);
        delete leaseMap[id];
    }
    // if lease is paid then deny
    // if contract-caller is not owner then deny
    // contract/escrow transfers nft back to contract-caller
    // update maps

    function getLastTokenId() external view returns (uint){
        return lastTokenId;
    }

    function getOwner(uint i) external view returns (address){
        return leaseMap[i].owner;
    }
    // Owner of a given token identifier

    // id, reciever
    function transfer(uint id, address addr) external{
        require(msg.sender==contractOwner,"Contract owner can transfer only");
        require(leaseMap[id]==address(0),"Cannot transfer property on lease");
        addr.transfer(propertyMap[id]);
    }
    // if property is on lease then deny
    // if contract-caller is not owner deny
    // transfer nft from contract-caller to reciever
    // update maps

}
