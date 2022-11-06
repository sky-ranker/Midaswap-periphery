// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface WETHERC20Lp{
  function balanceOf(address _account) external view returns (uint256);
  function transfer(address to, uint256 amount) external  returns (bool);
  function transferFrom( address from,address to, uint256 amount) external   returns (bool);
   function approve(address spender, uint256 amount) external returns (bool);

}

contract SwapPool {
  uint private unit=10**uint(18);
  uint private retainAmount= 10000000000000000;

  uint private  totalLpTokenA;
  address private tokenA;
  uint private worthA=10**uint(18);
  mapping(address=>uint) balancesLpTokenA;

  address private tokenB;
  uint private  scale;
  address payable private owner;

  event  stakekEvent(address staker,uint  amountA ,uint  amountB,uint  lpToKen);

  event  unStakeEvent(address staker,uint  amount,uint  lpToKen );

  event  receiveEvent(address staker,uint  amount);

  event  transferFormEvent(address owner,address to,uint amount );

  constructor (address _tokenA,address _tokenB,address swapAddress, uint _scale)  {
    owner = payable(swapAddress);
    tokenA = _tokenA;
    tokenB = _tokenB;
    scale = _scale;
  }

  function swapToB(uint  _amountA) public payable{
      require(WETHERC20Lp(tokenA).balanceOf(msg.sender) > _amountA,"Token is insufficient tokenA ");
     // WETHERC20Lp(tokenA).approve(address(this), _amountA);
      WETHERC20Lp(tokenA).transferFrom(msg.sender,address(this),_amountA);
      uint amountB= _amountA*scale/unit;
      transferFormB(msg.sender,amountB);

  }

  function swapToA(uint  _amountB) public payable{
      require(WETHERC20Lp(tokenB).balanceOf(msg.sender) > _amountB,"Token is insufficient tokenA ");
      //WETHERC20Lp(tokenB).approve(address(this), _amountB);
      WETHERC20Lp(tokenB).transferFrom(msg.sender,address(this),_amountB);
      uint amountA= _amountB*unit/scale;
      transferFormA(msg.sender,amountA);
      syncWorthA();
  }


   function syncWorthA() private {
     uint balanceAmountA = WETHERC20Lp(tokenA).balanceOf(address(this));
    if(balanceAmountA > 0){
        worthA =balanceAmountA*unit/totalLpTokenA;
    }else{
      worthA=10**uint(18);
    }
  }


  function stake(uint _amountA,uint _amountB) public payable{
    require(WETHERC20Lp(tokenA).balanceOf(msg.sender) > _amountA,"Token is insufficient tokenA ");
    require(WETHERC20Lp(tokenB).balanceOf(msg.sender) > _amountB,"Token is insufficient tokenB ");
    require(getTokenB(_amountA) == _amountB ,"amont is insufficient tokenB ");
    WETHERC20Lp(tokenA).transferFrom(msg.sender,address(this),_amountA);
    WETHERC20Lp(tokenB).transferFrom(msg.sender,address(this),_amountB);
    uint lpTokenA = _amountA*unit/worthA;
    totalLpTokenA+=lpTokenA;
    balancesLpTokenA[msg.sender]+=lpTokenA;
    emit stakekEvent(msg.sender, msg.value,_amountB,lpTokenA);
  }

  function getTokenB(uint amountA)public view returns(uint){
     return  amountA*scale/unit;
  }


  function unStake(uint lpAmountA) public payable {
    require( lpAmountA > 0,"Incorrect amount");
    require(balancesLpTokenA[msg.sender] >= lpAmountA,"Incorrect lpAmount");
    uint amountA= lpAmountA*worthA/unit;
    uint balanceAmountB = WETHERC20Lp(tokenB).balanceOf(address(this));
    uint amountB= (balanceAmountB*unit/totalLpTokenA)*lpAmountA/unit;
    totalLpTokenA -= lpAmountA;
    balancesLpTokenA[msg.sender]-=lpAmountA;
    transferFormA(msg.sender,amountA);
    transferFormB(msg.sender,amountB);
    emit unStakeEvent(msg.sender,lpAmountA,amountA);
  }


  function transferFormA(address to,uint amount) isAdmin public payable {
    uint total = WETHERC20Lp(tokenA).balanceOf(address(this));
    if(total > retainAmount){
      WETHERC20Lp(tokenA).transfer(to,amount);
      syncWorthA();
      emit transferFormEvent(msg.sender,to,amount);
    }
  }


   function transferFormB(address to,uint amount) isAdmin public payable {
     WETHERC20Lp(tokenB).transfer(to,amount);
     emit transferFormEvent(msg.sender,to,amount);
  }


  modifier isAdmin(){
    require(msg.sender == owner ,"only owner call this");
    _;
  }

  function getOwner() isAdmin view public returns(address) {
    return owner;
  }

  function  getLpToken() view public  returns(uint,uint){
     uint balanceAmountB = WETHERC20Lp(tokenB).balanceOf(address(this));
     uint amountA =  balancesLpTokenA[msg.sender]*unit/worthA;
     uint amountB= (balanceAmountB*unit/totalLpTokenA)*balancesLpTokenA[msg.sender]/unit;
    return (amountA,amountB);
  }

  function  getTotalBalance() view public returns(uint,uint) {
    return (WETHERC20Lp(tokenA).balanceOf(address(this)),WETHERC20Lp(tokenB).balanceOf(address(this)));
  }

}



