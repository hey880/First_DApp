const DappToken = artifacts.require('DappToken');
const DaiToken = artifacts.require('DaiToken');
const TokenFarm = artifacts.require('TokenFarm');

module.exports = async function(deployer, network, accounts) {
    //migration파일 배포자, smartcontract가 올라간 네트워크 그 자체,
    //가나쉬에서 볼 수 있는 계정들(이 계정들에게 토큰을 뿌리게 된다)

    //Deploy Mock DAI Token => 투자자로서 token farm에 투자(예금)할 토큰
    await deployer.deploy(DaiToken)
    const daiToken = await DaiToken.deployed() 
    //await 동작을 마치면 실제로 네트워크에서 DAI토큰을 가져옴.
    //token farm을 만들때마다 우리는 다시 TokenFarm의 constructor로 돌아가서
    //주소를(dai token의 주소) 넣어줘야 하니까.

    //Deploy Dapp Token => dai를 tokenFarm에 투자(예금)하고 받게 되는 이자같은 수익금
    await deployer.deploy(DappToken)
    const dappToken = await DappToken.deployed()

    //우리가 dapp token farm을 업데이트 할 때마다 아래 코드가 constructor의
    //매개변수를 통과하도록 하자.(아래 코드를 Deploy TokenFarm 처럼 수정)
    //deployer.deploy(TokenFarm) 

    //Deploy TokenFarm => bank 역할
    //dappToken address와 daiToken address를 전달함
    await deployer.deploy(TokenFarm, dappToken.address, daiToken.address)
    const tokenFarm = await TokenFarm.deployed()

    //여기서 two more 하고 싶어, 1. 모든 dapp 토큰을 token farm contract에 할당하고싶어
    //token farm은 bank고 그 안에 dai 토큰, dapp 토큰이 왔다갔다 하는 걸 구현할거야
    //그게 현실과 제일 비슷해

    //Transfer all tokens to TokenFarm (1 million)
    //1000000에 0을 18개 더 붙이 (DappToken.sol을 보면 18decimal, 즉 18진수라서)
    await dappToken.transfer(tokenFarm.address, '1000000000000000000000000')

    //Transfer 100 mock DAI token to investor(100)
    //가나쉬에서 첫번째([0]) account는 smart contract를 네트워크에 넣어서
    //deploy 하는 사람이고, 그 뒤부터는 investor들, 따라서 첫번째 investor는
    //accounts[1], 이 계정부터가 dai 토큰을 보유하고 프로젝트에 쓰기위해
    //dapp 토큰을 버는 투자자임
    await daiToken.transfer(accounts[1], '100000000000000000000')
}
