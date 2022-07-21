// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Router {
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts) {} 

  function getAmountsOut(
    uint amountIn, 
    address[] memory path
  )
    public
    view
    returns (uint[] memory amounts) {}

  function swapETHForExactTokens(
    uint amountOut, 
    address[] calldata path, 
    address to, 
    uint deadline
  )
  external
  payable
  returns (uint[] memory amounts){}

  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts){}

  function getAmountsIn(
    uint amountOut, 
    address[] memory path
  ) 
  public view returns (uint[] memory amounts){}

  function WETH() external pure returns (address){}

}

contract Contract {


    struct Spend { 
      uint256 totalSpend;
      uint256[] spendSplit;
    }

    Router router = Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function purchaseTokenSet(address[] memory tokenAddresses, uint[] memory amounts) public payable returns (uint256) {

        // check if the lengths match
        require(tokenAddresses.length == amounts.length, "Arrays must have the same length.");

        // check if you have enough money to make the trade
        Spend memory spend = getNetAmountIn(tokenAddresses, amounts);
        require(spend.totalSpend <= msg.value, "Not enough eth provided.");
        
        // make the trades
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        for(uint i=0;i<tokenAddresses.length;i++){
            path[1] = tokenAddresses[i];
            router.swapETHForExactTokens{value: spend.spendSplit[i]}(amounts[i], path, msg.sender, block.timestamp);
        }
        
        return spend.totalSpend;
    }

    function getNetAmountIn(address[] memory tokenAddresses, uint[] memory amounts) public view returns (Spend memory) {

      require(tokenAddresses.length == amounts.length, "Arrays must have the same length.");

        Spend memory spend;
        address[] memory path = new address[](2);
        spend.spendSplit = new uint256[](amounts.length);
        spend.totalSpend = 0;
        path[0] = router.WETH();
        for(uint i=0;i<tokenAddresses.length;i++){
            path[1] = tokenAddresses[i];
            spend.spendSplit[i] = router.getAmountsIn(amounts[i], path)[0];
            spend.totalSpend += spend.spendSplit[i];
        }
        return spend;
    }

}