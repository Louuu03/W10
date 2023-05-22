// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";


contract SimpleSwap is ISimpleSwap, ERC20("LPTOKEN", "LP") {
    uint256 private _reserveA; 
    uint256 private _reserveB;
    address private _tokenA;
    address private _tokenB;
    uint32  private _blockTimestampLast;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

    constructor(address addr1, address addr2){
        require(addr1.code.length > 0,"SimpleSwap: TOKEN_A_IS_NOT_CONTRACT");
        require(addr2.code.length > 0,"SimpleSwap: TOKEN_B_IS_NOT_CONTRACT");
        require(addr1 != addr2,"SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        _reserveA = 0;
        _reserveB = 0;
         if (addr1 < addr2) {
            _tokenA = addr1;
            _tokenB = addr2;
        } else {
            _tokenA = addr2;
            _tokenB = addr1;
        }
    }

     function swap(address tokenIn, address tokenOut, uint256 amountIn) external override returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(tokenIn == _tokenA || tokenIn == _tokenB, "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == _tokenA || tokenOut == _tokenB, "SimpleSwap: INVALID_TOKEN_OUT");
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        (uint256 _reserveA, uint256 _reserveB) = this.getReserves();
        uint256 k = _reserveA * _reserveB;
        if (tokenIn == _tokenA) {
            amountOut = amountIn * _reserveB / (_reserveA + amountIn);
        } else {
            amountOut = amountIn * _reserveA / (_reserveB + amountIn);
        }
        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        ERC20(tokenOut).transfer(msg.sender, amountOut);
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);

        _update();
        (_reserveA, _reserveB) = this.getReserves();
        require(_reserveA * _reserveB >= k, "SimpleSwap: K");
    }

    function addLiquidity(
        uint256 amountAIn, uint256 amountBIn
    ) external returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
    ){
        require(amountAIn > 0 && amountBIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        if (totalSupply() == 0) {
            amountA = amountAIn;
            amountB = amountBIn;
        } else {
            (amountA, amountB) = _quote(amountAIn, amountBIn);
        }
        liquidity = Math.sqrt(amountA * amountB);
        _mint(msg.sender, liquidity);
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);

        ERC20(_tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(_tokenB).transferFrom(msg.sender, address(this), amountB);
        _update();
        return (amountA, amountB, liquidity);
    }

    function removeLiquidity(uint256 liquidity) external returns (uint256 amountA, uint256 amountB)
    {
        require(liquidity > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");
        amountA = _reserveA * liquidity / totalSupply();
        amountB = _reserveB * liquidity / totalSupply();
        ERC20(address(this)).transferFrom(msg.sender, address(this), liquidity);
        _burn(address(this), liquidity);
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);

        ERC20(_tokenA).transfer(msg.sender, amountA);
        ERC20(_tokenB).transfer(msg.sender, amountB);
        return (amountA, amountB);
    }

    function getReserves() external view returns (uint256 reserveA, uint256 reserveB){
    return (_reserveA, _reserveB);
    }

    function getTokenA() external view returns (address tokenA){
    return _tokenA;
    }

    function getTokenB() external view returns (address tokenB){
        return _tokenB;
    }

     function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }
    function _quote(uint256 amountAIn, uint256 amountBIn)
        private
        view
        returns (uint256 actualAmountA, uint256 actualAmountB)
    {
        (uint256 reserveA, uint256 reserveB) = this.getReserves();
        if (amountAIn * reserveB > amountBIn * reserveA) {
            actualAmountA = amountBIn * reserveA / reserveB;
            actualAmountB = amountBIn;
        } else {
            actualAmountA = amountAIn;
            actualAmountB = amountAIn * reserveB / reserveA;
        }
    }

    function _update() private {
        _reserveA = ERC20(_tokenA).balanceOf(address(this));
        _reserveB = ERC20(_tokenB).balanceOf(address(this));
    }
}
