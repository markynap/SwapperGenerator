//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/*
    @title Proxyable a minimal proxy contract based on the EIP-1167 .
    @notice Using this contract is only necessary if you need to create large quantities of a contract.
        The use of proxies can significantly reduce the cost of contract creation at the expense of added complexity
        and as such should only be used when absolutely necessary. you must ensure that the memory of the created proxy
        aligns with the memory of the proxied contract. Inspect the created proxy during development to ensure it's
        functioning as intended.
    @custom::warning Do not destroy the contract you create a proxy too. Destroying the contract will corrupt every proxied
        contracted created from it.
*/
contract Proxyable {
    bool private proxy;

    /// @notice checks to see if this is a proxy contract
    /// @return proxy returns false if this is a proxy and true if not
    function isProxy() external view returns (bool) {
        return proxy;
    }

    /// @notice A modifier to ensure that a proxy contract doesn't attempt to create a proxy of itself.
    modifier isProxyable() {
        require(!proxy, "Unable to create a proxy from a proxy");
        _;
    }

    /// @notice initialize a proxy setting isProxy_ to true to prevents any further calls to initialize_
    function initialize_() external isProxyable {
        proxy = true;
    }

    /// @notice creates a proxy of the derived contract
    /// @return proxyAddress the address of the newly created proxy
    function createProxy() external isProxyable returns (address proxyAddress) {
        // the address of this contract because only a non-proxy contract can call this
        bytes20 deployedAddress = bytes20(address(this));
        assembly {
        // load the free memory pointer
            let fmp := mload(0x40)
        // first 20 bytes of built in proxy bytecode
            mstore(fmp, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
        // store 20 bytes from the target address at the 20th bit (inclusive)
            mstore(add(fmp, 0x14), deployedAddress)
        // store the remaining bytes
            mstore(add(fmp, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        // create a new contract using the proxy memory and return the new address
            proxyAddress := create(0, fmp, 0x37)
        }
        // intiialize the proxy above to set its isProxy_ flag to true
        Proxyable(proxyAddress).initialize_();
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IGenerator {
    function getOwner() external view returns (address);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract SwapperProxyData {
    address public token;
    IUniswapV2Router02 public router;
    IGenerator public generator;
    address[] internal path;
}

/**
    Basic Swapper Contract, Allowing People To Purchase Tokens From A DEX
    Without The Need For Wallet Connection

    Best If Used With Taxed Tokens To Avoid Front Running

    Developed By: DeFi Mark
 */
contract SwapperProxy is SwapperProxyData, Proxyable {

    function __init__(
        address token_,
        address DEX_
    ) external {
        require(
            token == address(0),
            'Already Initialized'
        );
        token = token_;
        router = IUniswapV2Router02(DEX_);
        generator = IGenerator(msg.sender);
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = token_;
    }

    receive() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    function buyToken(address recipient, uint minOut) external payable {
        _buyToken(recipient, msg.value, minOut);
    }

    function buyToken(address recipient) external payable {
        _buyToken(recipient, msg.value, 0);
    }

    function buyToken() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    function _buyToken(address recipient, uint value, uint minOut) internal {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: value}(
            minOut,
            path,
            recipient,
            block.timestamp + 300
        );
    }

    function withdraw(IERC20 token) external {
        token.transfer(
            generator.getOwner(),
            token.balanceOf(address(this))
        );
    }

    function withdraw() external {
        (bool s,) = payable(generator.getOwner()).call{value: address(this).balance}("");
        require(s);
    }
}