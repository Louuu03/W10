// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    uint256 private reserveA; 
    uint256 private reserveB;
        address private tokenA;
    address private tokenB;
    uint32  private blockTimestampLast;
constructor(address t0, address t1) ERC20("LPTOKEN", "LP"){
        require(_isContract(t0),"SimpleSwap: TOKEN_A_IS_NOT_CONTRACT");
        require(_isContract(t1),"SimpleSwap: TOKEN_B_IS_NOT_CONTRACT");
        require(t0 != t1,"SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        _reserve1 = 0;
        _reserve2 = 0;
        // _tokenA should be lower then _tokenB so we need to do the sort first
        (_tokenA, _tokenB) = _sortTokens(t0, t1); 
    }
 function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut){};
     function addLiquidity(uint256 amountAIn, uint256 amountBIn)
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ){};
        function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB){};
function getReserves() external view returns (uint256 reserveA, uint256 reserveB){};
function getTokenA() external view returns (address tokenA){
    return
};
    function getTokenB() external view returns (address tokenB){};   
}
