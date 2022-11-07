// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;


import "./VToken.sol";

interface Erc721 {
   function approve(address to, uint256 tokenId) external;
   function transferFrom(  address from, address to, uint256 tokenId ) external;
}

interface Erc1155 {
  function setApprovalForAll(address operator, bool approved) external;
   function safeTransferFrom ( address from, address to, uint256 id,  uint256 amount,  bytes memory data) external;
}

contract FractionNFT  {
    mapping(address =>address) nftVTokenMap721;
    mapping(address =>mapping(uint256 =>address)) nftVTokenMap1155;


    function getVtokenAddress721(address nftAddress)public view returns(address) {
        return nftVTokenMap721[nftAddress];
    }

    function getVtokenAddress1155(address nftAddress,uint256 id)public view returns(address) {
        return nftVTokenMap1155[nftAddress][id];
    }

    function create(address nftAddress,uint  id ) public returns(address) {
        if(id >0 ){
            require(nftVTokenMap721[nftAddress] != address(0));
            nftVTokenMap721[nftAddress]= address(new  VTOKEN("VTOKEN","VTOKEN"));
            return nftVTokenMap721[nftAddress];  
        }else{
            require(nftVTokenMap1155[nftAddress][id] != address(0));
            nftVTokenMap1155[nftAddress][id]= address(new  VTOKEN("VTOKEN","VTOKEN"));
            return nftVTokenMap1155[nftAddress][id];  
        }
    }

    function exchange721(address nftAddress,uint256 tokenId )public returns(address){
        if(!isExistAddress(nftAddress)){
            nftVTokenMap721[nftAddress]= address(new  VTOKEN("VTOKEN","VTOKEN"));
        }
        VTOKEN(nftVTokenMap721[nftAddress]).mint(msg.sender, 1);
        Erc721(nftAddress).approve(address(this), tokenId);
        Erc721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        return nftVTokenMap721[nftAddress];
    }


    function exchange1155(address nftAddress,uint256 id, uint256 amount)public  returns(address){
        VTOKEN(nftVTokenMap1155[nftAddress][id]).mint(msg.sender, amount);
        Erc1155(nftAddress).setApprovalForAll(address(this), true);
        Erc1155(nftAddress).safeTransferFrom(msg.sender, address(this), id,amount,'0x');
        return nftVTokenMap1155[nftAddress][id];
    }

    function isExistAddress(address nftAddress) public view returns(bool){
        return nftVTokenMap721[nftAddress] != address(0);
    }

}