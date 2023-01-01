// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract contracting{
    // a public contract between an employer and a contractor by consulting a superviser
    // employer address can send and recieve token
    address payable employer;
    // contractor address can send and receive token
    address payable contractor;
    // superviser address
    address superviser;
    // total days that a contract should work in
    uint16 public day;
    // total cost of the contract in which the cemployer must pay if contract ended properly
    uint contractCost;
    // the guarantee fee that the contractor must pay if the contract faild
    uint guarantee;
    //starting date of the contract
    uint StartDate;

    // checking the status of the contract
    enum projectStatus {
        notStarted , started , paid , ended, suspended , failed
    }
    projectStatus currentStatus;

    // constructor which must be fullfilde at th ebegining of the contract
    // icludes of employer, contractor, superviser
    // the total days of contract length
    // total price of the contract and the guarantee fee
    constructor (
        address payable employer_, 
        address payable contractor_, 
        address superviser_,
        uint16 day_,
        uint contractCost_,
        uint guarantee_
    ) public {
        employer = employer_;
        contractor = contractor_;
        superviser = superviser_;
        day = day_;
        contractCost = contractCost_;
        guarantee = guarantee_;
        currentStatus = projectStatus.notStarted;
    }

    //pay function
    //the employer must run this function when it's not started yet
    // the employer must pay the contract value
    function pay()public payable returns(string memory){
        require(currentStatus == projectStatus.notStarted , "the contractor is already started");
        require(msg.sender == employer , "the caller is not employer");
        require(msg.value == contractCost, "the value of the contract is not set correctly ");
        currentStatus = projectStatus.paid; 
        StartDate = block.timestamp;
        return "The contract is paid successfully";
    }

    //Guarantee function
    //the contractor must run this function when it's paid by th eemployer
    // the contractor must pay the contract guarantee
    // the contract will be started
    function guaranteeDeposit() public payable returns(string memory){
        require(msg.sender == contractor , "the caller must be contractor");
        require(msg.value == guarantee, "the value of the guarantee is not set correctly ");
        require(currentStatus == projectStatus.paid , "the employer hasn't paid the contract yet");
        currentStatus = projectStatus.started; 
        return "The contract is started successfully";
    }

    //confirm function
    //the employer must run this function when it's done by the contractor
    // the employer will check the contract and will confirm it or suspend it
    function confirm (bool _ok)public returns(string memory){
        require(msg.sender == employer , "the caller is not employer");
        require(currentStatus == projectStatus.started , "the contract is not started yet");   
        if(_ok == true){
            currentStatus = projectStatus.ended;
            return "The contract is ended successfully";
        } else if(block.timestamp >= ((day * 84600)+StartDate)){
            currentStatus = projectStatus.suspended;
            return "The contract is suspended";
        } else{
            return "The deadline is not over";
        }
        
    }


    //judge function
    //the supervisor must run this function when it's suspended
    // the supervisor will check the contract finally and will confirm it or reject it
    function judge(bool _checked)public returns(string memory)  {
        require(currentStatus == projectStatus.suspended , "the contract doesn't work and it's suspended ");   
        require(msg.sender == superviser , "the caller is not superviser");
         if(_checked == true){
            currentStatus = projectStatus.ended;
            return "The contract is ended successfully";
        } else {
        currentStatus = projectStatus.failed;
            return "The contract is failed";
        }
    }

    // checking the project status
    function checkProjectStatus()public view returns(projectStatus){
        return currentStatus;
    }

    // withdraw contract
    // the contract is finished succcessfully 
    // the contractor can get the amount of the contract and the gurarantee
    function withdrawContract()public payable returns(string memory){
        require(msg.sender == contractor , "the caller must be contractor");
        require(currentStatus == projectStatus.ended , "the contract is not finished successfully ");   
        contractor.transfer(contractCost + guarantee);
        return "The contract is paid successfully to the contractor";
    }

    // withdraw employer
    // the contract is failed
    // the employer can get the amount of the contract and the gurarantee
    function withdrawEmployer()public payable returns(string memory){
        require(msg.sender == employer , "the caller must be contractor");
        require(currentStatus == projectStatus.failed , "the contract is failed ");
        employer.transfer(contractCost + guarantee); 
        return "The contract is failed and the employer get the guarantee";
    }




}