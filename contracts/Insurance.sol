//SPDX-License-Identifier: UNLICENSED
pragma solidity >0.7.0 <=0.9.0;

contract InsuranceFactory
{
    address[] public deployedPolicies;

    event PolicyCreated(
        string car_model,
        string car_make,
        string reg_number,
        string manufacture_date,
        address indexed insurer,
        address indexed owner,
        address policyAddress,
        uint indexed timestamp
    );

    function createPolicy(
        address payable _owner, address payable _insurer, string memory _car_model, string memory _car_make, string memory _reg_number, string memory _manufacture_date) public
    {

        InsuranceContract newInsurance = new InsuranceContract(_owner,_insurer,_car_model, _car_make, _reg_number,_manufacture_date);
        

        deployedPolicies.push(address(newInsurance));

        emit PolicyCreated(
            _car_model,
            _car_make, 
            _reg_number,
            _manufacture_date,
            _insurer, 
            msg.sender, 
            address(newInsurance),
            block.timestamp
        );

    }
}
contract InsuranceContract {

    enum PolicyStatus { InsuranceApplied, InsuranceGranted, Active, Expired, ClaimApplied, ClaimApproved }
        
        string private car_model;
        string private car_make;
        string private reg_number;
        string private manufacture_date;
        address payable policyHolder;
        address payable insurer;
        uint private insuredAmount;
        uint private premiumAmount;
        uint private duration;
        uint private startDate;
        uint private endDate;
        uint private totalAmount;
        PolicyStatus policyStatus;

    constructor(address payable _owner,address payable _insurer, string memory _car_model, string memory _car_make, string memory _reg_number, string memory _manufacture_date)
    {
        require(msg.sender!=_insurer, "Insurer and policy holder cannot be same");
        policyHolder = _owner;
        insurer = _insurer;
        car_model = _car_model;
        car_make = _car_make;
        reg_number = _reg_number;
        manufacture_date = _manufacture_date;
    }

    function VehicleDetails () public view returns (string memory, string memory, string memory , string memory)
    {
        require(msg.sender==insurer || msg.sender==policyHolder, "Only insurer and policy holder can view the application.");
        return(car_model,car_make,reg_number,manufacture_date);
    } 

    function PolicyDetails () public view returns (address, address, uint , uint , uint , uint , uint, string memory )
    {
        require(msg.sender==insurer || msg.sender==policyHolder, "Only insurer and policy holder can view the application.");
        return (policyHolder, insurer ,insuredAmount, premiumAmount, duration, startDate, endDate, getPolicyStatus());
    }

    function getPolicyStatus() private view returns(string memory){
        string memory status;
        if(policyStatus==PolicyStatus.InsuranceApplied)
        {
            status = "Insurance Applied";
        }
        else if(policyStatus==PolicyStatus.InsuranceGranted)
        {
            status = "Insurance Granted";
        }        
        else if(policyStatus==PolicyStatus.Active)
        {
            status = "Active";
        }        
        else if(policyStatus==PolicyStatus.Expired)
        {
            status = "Expired";
        }
        else if(policyStatus==PolicyStatus.ClaimApplied)
        {
            status = "Claim Applied";
        }
                else if(policyStatus==PolicyStatus.ClaimApproved)
        {
            status = "Claim Approved";
        }
        return (status);
    }

    //Funtion to grant the insurance
    function grantInsurance(uint _insuredAmount, uint _premiumAmount, uint _duration) public payable{
        require(msg.sender==insurer, "Only insurer can grant the insurance");
        require(policyStatus == PolicyStatus.InsuranceApplied, "Insurance not applied");
        require(msg.value==(_insuredAmount-_premiumAmount), "Insurance Amount is not correct");
        insurer = payable(msg.sender);
        insuredAmount = _insuredAmount;
        premiumAmount = _premiumAmount;
        duration = _duration;
        startDate = block.timestamp;
        endDate = startDate + _duration;
        totalAmount = _insuredAmount-_premiumAmount;
        policyStatus = PolicyStatus.InsuranceGranted;

    }
    
    // Function to pay the premium amount
    function payPremium() public payable {
        require(msg.sender == policyHolder, "Only policy holder can pay the premium.");
        require(policyStatus == PolicyStatus.InsuranceGranted, "Insurance has not been granted.");
        require(msg.value == premiumAmount, "Premium amount is incorrect.");
        require(totalAmount!=insuredAmount, "You have paid the premium");
        
        totalAmount += msg.value;
        policyStatus = PolicyStatus.Active;
    }
    
    // Function to expire the policy
    function expirePolicy() public {
        require(msg.sender == insurer, "Only insurer can expire the policy.");
        require(block.timestamp >= endDate, "Policy has not expired yet.");
        
        uint amount = totalAmount;
        payable(insurer).transfer(amount);
        policyStatus = PolicyStatus.Expired;
    }
    
    // Function to apply the claim on insurance
    function applyClaim() public {
        require(msg.sender == policyHolder, "Only policy holder can claim the insurance.");
        require(policyStatus == PolicyStatus.Active, "Policy is not active.");
        require(block.timestamp < endDate, "Policy has expired.");
        
        policyStatus = PolicyStatus.ClaimApplied;
        
    }

    // Function to approve the claim on insurance
    function approveClaim() public {
        require(msg.sender == insurer, "Only insurer can approve the insurance claim.");   
        require(policyStatus == PolicyStatus.ClaimApplied, "No Claim has been applied.");    
        uint amount = insuredAmount;
        payable(policyHolder).transfer(amount);
        policyStatus = PolicyStatus.ClaimApproved;
    }

    function denyClaim() public {
        require(msg.sender == insurer, "Only insurer can deny the insurance claim.");   
        require(policyStatus == PolicyStatus.ClaimApplied, "No Claim has been applied.");   
        policyStatus = PolicyStatus.Active; 
    }
}