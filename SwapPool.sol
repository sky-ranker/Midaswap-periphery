// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface WETHERC20Lp{
    function balanceOf(address _account) external view returns (uint256);
    function transferFrom( address from,address to, uint256 amount) external   returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external  returns (bool);
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

    function swap(address sender, address toAddress, uint _amount) public payable{
        if(tokenA == toAddress){
            require(WETHERC20Lp(tokenB).balanceOf(sender) > _amount,"Token is insufficient tokenB ");
            WETHERC20Lp(tokenB).transferFrom(sender,address(this),_amount);
            WETHERC20Lp(tokenA).transfer(sender,getToken(toAddress,_amount));
        }else{
            require(WETHERC20Lp(tokenA).balanceOf(sender) > _amount,"Token is insufficient tokenA ");
            WETHERC20Lp(tokenA).transferFrom(sender,address(this),_amount);
            WETHERC20Lp(tokenB).transfer(sender,getToken(toAddress,_amount));
        }
    }


    function syncWorthA() private {
        uint balanceAmountA = WETHERC20Lp(tokenA).balanceOf(address(this));
        if(balanceAmountA > 0){
            worthA =balanceAmountA*unit/totalLpTokenA;
        }else{
            worthA=10**uint(18);
        }
    }


    function stake(address sender,uint _amountA,uint _amountB) public {
        require(WETHERC20Lp(tokenA).balanceOf(sender) >= _amountA,"Token is insufficient tokenA ");
        require(WETHERC20Lp(tokenB).balanceOf(sender) >= _amountB,"Token is insufficient tokenB ");
        require(getToken(tokenB,_amountA) == _amountB ,"amont is insufficient tokenB ");
        WETHERC20Lp(tokenA).transferFrom(sender,address(this),_amountA);
        WETHERC20Lp(tokenB).transferFrom(sender,address(this),_amountB);
        uint lpTokenA = _amountA*unit/worthA;
        totalLpTokenA+=lpTokenA;
        balancesLpTokenA[sender]+=lpTokenA;
        emit stakekEvent(sender, _amountA,_amountB,lpTokenA);
    }



    function getToken(address toAddress,uint amount)public view returns(uint){
        if(tokenB == toAddress){
            return  amount*scale/unit;
        }else{
            return  amount*unit/scale;
        }
    }


    function unStake(address sender,uint lpAmountA) public payable {
        require( lpAmountA > 0,"Incorrect amount");
        require(balancesLpTokenA[sender] >= lpAmountA,"Incorrect lpAmount");
        uint amountA= lpAmountA*worthA/unit;
        uint balanceAmountB = WETHERC20Lp(tokenB).balanceOf(address(this));
        uint amountB= (balanceAmountB*unit/totalLpTokenA)*lpAmountA/unit;
        totalLpTokenA -= lpAmountA;
        balancesLpTokenA[sender]-=lpAmountA;
        WETHERC20Lp(tokenA).transferFrom(address(this),sender,amountA);
        WETHERC20Lp(tokenB).transferFrom(address(this),sender,amountB);
        emit unStakeEvent(sender,lpAmountA,amountA);
    }


    modifier isAdmin(){
        require(msg.sender == owner ,"only owner call this");
        _;
    }

    function getOwner() isAdmin view public returns(address) {
        return owner;
    }

    function  getLpToken(address _owner) view public  returns(uint,uint){
        uint balanceAmountB = WETHERC20Lp(tokenB).balanceOf(address(this));
        uint amountA =  balancesLpTokenA[_owner]*unit/worthA;
        uint amountB= (balanceAmountB*unit/totalLpTokenA)*balancesLpTokenA[_owner]/unit;
        return (amountA,amountB);
    }

    function  getTotalBalance() view public returns(uint,uint) {
        return (WETHERC20Lp(tokenA).balanceOf(address(this)),WETHERC20Lp(tokenB).balanceOf(address(this)));
    }

}

