// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;


import "./VTOKEN.sol";

interface ERCNft{
     function transferFrom721(  address from, address to, uint256 tokenId )  external;
     function transferFrom1155(  address from, address to, uint256 id,uint256 amount,bytes memory data)  external;
}


contract FractionNFT  {

    mapping(address =>address) nftVTokenMap721;
    mapping(address =>mapping(uint256 =>address)) nftVTokenMap1155;
    mapping (address=>mapping (address=>uint256))  nftAmount721;
    mapping (address=> mapping (address=>mapping(uint256 =>uint256))) nftAmount1155;

    function exchange721(address nftAddress,uint256 tokenId )public payable{
        if(!isExistAddress(nftAddress)){
            nftVTokenMap721[nftAddress]= address(new  VTOKEN("VTOKEN","VTOKEN"));
        }
        VTOKEN(nftVTokenMap721[nftAddress]).mint(msg.sender, 1);
        ERCNft(nftAddress).transferFrom721(msg.sender, address(this), tokenId);
        nftAmount721[nftAddress][msg.sender]=tokenId;
    }


    function exchange1155(address nftAddress,uint256 id, uint256 amount)public payable{
        if(!isExistAddress(nftAddress)){
            nftVTokenMap1155[nftAddress][id]= address(new  VTOKEN("VTOKEN","VTOKEN"));
        }
        VTOKEN(nftVTokenMap1155[nftAddress][id]).mint(msg.sender, amount);
        ERCNft(nftAddress).transferFrom1155(msg.sender, address(this), id,amount,'0x');
        nftAmount1155[nftAddress][msg.sender][id]=nftAmount1155[nftAddress][msg.sender][id]+amount;
    }

    function isExistAddress(address nftAddress) public view returns(bool){
        return nftVTokenMap721[nftAddress] != address(0);
    }



}