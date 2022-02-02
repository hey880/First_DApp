const TokenFarm = artifacts.require('TokenFarm');

// truffle은 앱 전체를 load 하는 스크립트를 허용한다. 
// 이 스크립트가 템플릿 스크립트가 될 것.
// truffle exec scripts/issue-token.js로 실행해보자. console log내용이 출력된다.
// tokenFarm 불러와서 issueTokens() 호출 하는 코드 작성을 마쳤으면
// truffle migrate --reset 명령어를 실행한다.
module.exports = async function(callback) {
    let tokenFarm = await TokenFarm.deployed()
    await tokenFarm.issueTokens()
    // Code goes here..
    console.log("Tokens issued!")
    callback()
}