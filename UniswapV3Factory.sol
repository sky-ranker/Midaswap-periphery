// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./SwapPool.sol";
import "./FractionNFT.sol";

contract UniswapV3Router {
    //nft-> tokenA->tokenB pools address
    mapping(address => mapping(address=> mapping(address=>address))) private  getPool721;
        //nft-> tokenA->tokenB id pools
    mapping(address => mapping(address=> mapping(address=> mapping(uint256=>address)))) private   getPool1155;
    
    mapping(address => address[]) private   poolsTokenMap;

    address[]  private poolsAddressArray;

    address private fractionNFTAddress;

    constructor ()  {
         fractionNFTAddress= address(new  FractionNFT());
    }


    

    function getPoolAddress(address nft_address,address tokenB,uint  id ) public  view  returns(address) {
        if(id > 0){
             address vtokenAddress = FractionNFT(fractionNFTAddress).getVtokenAddress1155(nft_address,id);
             return    getPool1155[nft_address][vtokenAddress][tokenB][id];
        }else{
          address vtokenAddress = FractionNFT(fractionNFTAddress).getVtokenAddress721(nft_address);
          return   getPool721[nft_address][vtokenAddress][tokenB];
        }
    }

    function getVtoken(address nft_address,uint  id) public  view  returns(address) {
         if(id > 0){
             return  FractionNFT(fractionNFTAddress).getVtokenAddress1155(nft_address,id);
         }else{
               return  FractionNFT(fractionNFTAddress).getVtokenAddress721(nft_address);
         }
    }



   function getToken(address pools,address toAddress, uint amountA)public view returns(uint){
        return  SwapPool(pools).getToken(toAddress,amountA);
    }


    function swap(address pools,address toAddress ,uint _amount) public {
          SwapPool(pools).swap(toAddress,_amount);
    }

    function createPool(address nft_address,uint  id ,address tokenB ,uint scale) public {
          if(id > 0){
                address  vtokenAddress = FractionNFT(fractionNFTAddress).create(nft_address,id);
                address pools = getPool1155[nft_address][vtokenAddress][tokenB][id];
                    if(pools == address(0)){
                    pools= address(new  SwapPool(vtokenAddress,tokenB,address(this),scale));
                    getPool1155[nft_address][vtokenAddress][tokenB][id]=pools;
                }
          }else{
                address  vtokenAddress =  FractionNFT(fractionNFTAddress).create(nft_address,id);
                address pools = getPool721[nft_address][vtokenAddress][tokenB];
                 if(pools == address(0)){
                    pools= address(new  SwapPool(vtokenAddress,tokenB,address(this),scale));
                    getPool721[nft_address][vtokenAddress][tokenB]=pools;
                }

          }
    }
    

    



    function addPool721(address nft_address,address tokenB ,uint256 tokenId,uint _amountA,uint _amountB) public {
        address vtokenAddress = FractionNFT(fractionNFTAddress).exchange721(nft_address,tokenId);
        address pools=  getPool721[nft_address][vtokenAddress][tokenB];
        require(pools != address(0));
        SwapPool(pools).stake(_amountA, _amountB);
    }


    function addPool1155(address nft_address,uint256 id,address tokenB,uint _amountA,uint _amountB)public {
        address vtokenAddress = FractionNFT(fractionNFTAddress).exchange1155(nft_address,id,_amountA);
        address pools=  getPool1155[nft_address][vtokenAddress][tokenB][id];
        SwapPool(pools).stake(_amountA, _amountB);
    }


     function unStake721(address nft_address,address tokenB ,uint lpAmount) public {
        address vtokenAddress = FractionNFT(fractionNFTAddress).getVtokenAddress721(nft_address);
        address pools=  getPool721[nft_address][vtokenAddress][tokenB];
        SwapPool(pools).unStake(lpAmount);
    }


    function unStake1155(address nft_address,uint256 id,address tokenB ,uint lpAmount) public {
        address tokenA = FractionNFT(fractionNFTAddress).getVtokenAddress1155(nft_address,id);
        address pools=  getPool1155[nft_address][tokenA][tokenB][id];
        SwapPool(pools).unStake(lpAmount);
    }




}