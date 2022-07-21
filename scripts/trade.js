const Router = artifacts.require('Router.sol');
const Weth = artifacts.require('Weth.sol');
const Bat = artifacts.require('Bat.sol');

const ROUTER_ADDRESS = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const WETH_ADDRESS = '0xc778417E063141139Fce010982780140Aa0cD5Ab';
const BAT_ADDRESS = '0xbF7A7169562078c96f0eC1A8aFD6aE50f12e5A99'; 

const amountIn = web3.utils.toWei('0.1');

module.exports = async done => {
  try {
    const [admin, _] = await web3.eth.getAccounts();
    const router = await Router.at(ROUTER_ADDRESS);
    const weth = await Weth.at(WETH_ADDRESS);
    const bat = await Bat.at(BAT_ADDRESS);

    await weth.deposit({value: amountIn}) 
    await weth.approve(router.address, amountIn);

    const amountsOut = await router.getAmountsOut(amountIn, [WETH_ADDRESS, BAT_ADDRESS]);
    console.log('A1');
    console.log(amountsOut);
    const amountOutMin = amountsOut[1]
        .mul(web3.utils.toBN(90))
        .div(web3.utils.toBN(100));
    const balanceBatBefore = await bat.balanceOf(admin);
    console.log('A2');
    console.log(balanceBatBefore);

    await router.swapExactTokensForTokens(
      amountIn, 
      amountOutMin,
      [WETH_ADDRESS, BAT_ADDRESS],
      admin,
      Math.floor((Date.now() / 1000)) + 60 * 10
    );

    const balanceBatAfter = await bat.balanceOf(admin);
    console.log('A3');
    console.log(balanceBatAfter);
    const executionPerf = balanceBatAfter.sub(balanceBatBefore).div(amountsOut[1]);
    console.log('A4');
    console.log(executionPerf.toString());
  } catch(e) {
    console.log(e);
  }
  done();
};
