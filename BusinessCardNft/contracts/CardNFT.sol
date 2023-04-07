// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract cardNft is ERC721Enumerable, Ownable {

    //NFT 이름과 심볼 정의
    string private _name = "BusinessCard";
    string private _symbol = "BC";

    //명함 정보를 저장하기 위한 구조체 정의
    struct Card {
        string name; //유저이름
        string group; //조직이름
        string job; //직장
        string phone; //핸드폰번호
        address owner; // 소유주
        address issuer; // 발급자
    }

    //명함 발급 비용
    uint256 private _issueCost = 1 ether;
    //조직 명함 발급 비용
    uint256 private _orgIssueCost = 1 ether;
    //최초 1회 mint 명함 수
    uint256 private _mintLimit = 10;
    //조직권한 예치 비용
    uint256 private _deposit = 2 ether;

    //조직멤버 여부 조회 매핑
    mapping(address => bool) private members;
    //조직원 조직이름 매핑
    mapping(address => string) private orgName;
    //명함 발급시 필요한 유저 정보 매핑
    mapping(uint256 => Card) userData;

    constructor() ERC721(_name, _symbol) {}

    // 개인 명함 발급 비용 변경
    function setCost(uint256 newCost) external onlyOwner {
        _issueCost = newCost;
    }

    //조직 발급 비용 변경
    function setOrgCost(uint256 newCost) external onlyOwner {
        _orgIssueCost = newCost;
    }

    //조직 권한 예치
    function deposit(string memory _orgName) external payable {
        require(msg.value == _deposit, "Incorrect deposit amount");
        members[msg.sender] = true;
        orgName[msg.sender] = _orgName;
    }


    //명함 발급
    function issueCard(string memory _name, string memory _group, string memory _job, string memory _phone) external payable {
        uint tokenId;

        //최초 mint 무료 수행
        if (balanceOf(msg.sender) == 0) {
            for(uint i = 0; i < _mintLimit; i++) {
                tokenId = totalSupply() + 1;
                _safeMint(msg.sender, tokenId);
                userData[tokenId] = Card(_name, _group, _job, _phone, msg.sender, msg.sender);
            }
        } else {
            require(msg.value == _issueCost, "Incorrect price");
            payable(owner()).transfer(_issueCost);

            for(uint i = 0; i < _mintLimit; i++) {
                tokenId = totalSupply() + 1;
                _safeMint(msg.sender, tokenId);
                userData[tokenId] = Card(_name, _group, _job, _phone, msg.sender, msg.sender);
            }
        }
    }

    //개인 명함 발급가능 가격 조회
    function getCardCost() external view returns (uint256){
        return _issueCost;
    }

    //조직이 멤버 명함 발급
    function issueOrgCard(string memory _name, string memory _group, string memory _job, string memory _phone, address member) external payable {
        //발급 권한확인
        require(msg.value == _orgIssueCost, "Incorrect deposit amount");
        require(members[msg.sender], "You are not authorized to issue cards");
        require(members[member], "Target is not registered with the organization");
        //같은 조직일때만 가능
        require(keccak256(abi.encodePacked(orgName[msg.sender])) == keccak256(abi.encodePacked(orgName[member])), "Not in the same organizaion");

        for(uint i = 0; i < _mintLimit; i++) {
            uint tokenId;
            tokenId = totalSupply() + 1;
            _safeMint(member, tokenId);
            userData[tokenId] = Card(_name, orgName[msg.sender], _job, _phone, member, msg.sender);
        }
    
    }

    function transferCard(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(from, tokenId), "YOU ARE NOT THE OWNER OF NFT");
        require(to != address(0), "CAN NOT TRANSFER TO ZERO ADDRESS");
        _transfer(from, to, tokenId);
    }

}