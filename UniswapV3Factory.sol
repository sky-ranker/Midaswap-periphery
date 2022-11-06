// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./SwapPool.sol";
import "./FractionNFT.sol";

contract UniswapV3Factory {
    //nft-> tokenA->tokenB pools address
    mapping(address => mapping(address=> mapping(address=>address))) public  getPool721;
        //nft-> tokenA->tokenB id pools
    mapping(address => mapping(address=> mapping(address=> mapping(uint256=>address)))) public  getPool1155;
    
    address[]  private poolsAddressArray;

    address private fractionNFTAddress;

    constructor ()  {
         fractionNFTAddress= address(new  FractionNFT());
    }



    function swapToB_721(address nft_address,address tokenB ,uint _amountA) public {
          address vtokenAddress = FractionNFT(fractionNFTAddress).getVtokenAddress721(nft_address);
          address pools=  getPool721[nft_address][vtokenAddress][tokenB];
          SwapPool(pools).swapToB(_amountA);
    }

    function swapToB_1155(address nft_address,address tokenB ,uint256 id,uint _amountA) public {
          address tokenA = FractionNFT(fractionNFTAddress).getVtokenAddress1155(nft_address,id);
          address pools=  getPool1155[nft_address][tokenA][tokenB][id];
          SwapPool(pools).swapToB(_amountA);
    }

    
    function swapToA_721(address nft_address,address tokenB ,uint _amountB) public {
          address vtokenAddress = FractionNFT(fractionNFTAddress).getVtokenAddress721(nft_address);
          address pools=  getPool721[nft_address][vtokenAddress][tokenB];
          SwapPool(pools).swapToA(_amountB);
    }


    function swapToA_1155(address nft_address,address tokenB ,uint256 id,uint _amountB) public {
          address tokenA = FractionNFT(fractionNFTAddress).getVtokenAddress1155(nft_address,id);
          address pools=  getPool1155[nft_address][tokenA][tokenB][id];
          SwapPool(pools).swapToA(_amountB);
    }



    function addPool721(address nft_address,address tokenB ,uint256 tokenId,uint _amountA,uint _amountB,uint scale) public {
        address vtokenAddress = FractionNFT(fractionNFTAddress).exchange721(nft_address,tokenId);
        address pools=  getPool721[nft_address][vtokenAddress][tokenB];
        if(pools == address(0)){
            pools= address(new  SwapPool(vtokenAddress,tokenB,address(this),scale));
            getPool721[nft_address][vtokenAddress][tokenB]=pools;
            poolsAddressArray.push(pools);
        }
        SwapPool(pools).stake(_amountA, _amountB);
    }


    function addPool1155(address nft_address,uint256 id,address tokenB,uint _amountA,uint _amountB,uint scale)public payable{
        address vtokenAddress = FractionNFT(fractionNFTAddress).exchange1155(nft_address,id,_amountA);
        address pools=  getPool1155[nft_address][vtokenAddress][tokenB][id];
        if(pools == address(0)){
            pools= address(new  SwapPool(vtokenAddress,tokenB,address(this),scale));
             getPool1155[nft_address][vtokenAddress][tokenB][id]=pools;
             poolsAddressArray.push(pools);
        }
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