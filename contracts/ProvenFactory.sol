// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTProject.sol";

contract ProvenFactory is Ownable{

    NFTProject[] public projects;
    mapping(address => NFTProject) public addressToProject;
    
    event OnProjectCreated(address contact_address);

    constructor() {
    }

    function createProject(address _project_address) public {

        //require(IERC721(_project_address).supportsInterface(type(Ownable).interfaceId), "Project not ownable");

        require(msg.sender == Ownable(_project_address).owner(), "Not authorized to create this project.");

        NFTProject project = new NFTProject(address(this), _project_address);

        projects.push(project);

        addressToProject[address(_project_address)] = project;

        emit OnProjectCreated(address(project));
    }

    function removeProject(address _project_address) public onlyOwner {
        delete addressToProject[_project_address];
    }
}