pragma solidity >= 0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    // All code goes here...
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;

    constructor (DappToken _dappToken, DaiToken _daiToken) public {
        //생성자의 매개변수로 _dappToken, _daiToken을 넣는데 이 변수들의
        //타입은 DappToken, DaiToken, 즉, smart contract 그 자체다.
        //이 매개변수들에 dapptoken address, daitoken address를 패스한다.
        dappToken = _dappToken;
        daiToken = _daiToken;
        //이 address 들은 지역변수이므로 다른 함수들이 접근할 수 있도록 하기
        //위해서 상태변수에 저장합니다.(위 처럼)
    }

    // 1. Stakes Tokens (Deposit)
    function stakeTokens(uint _amount) public {
        //매개변수는 stake할 토큰의 양
        //smart contract 밖에서 누군가가 호출할 수 있어야 되므로 public으로 선언
        //이건 investor의 지갑에서 이 smart contract로 DAI 토큰을 전송하기 위한 함수

        // Transfer Mock Dai tokens to this contract for staking
        // msg.sender는 솔리디티에 내장된 변수, msg는 솔리디티에 내장된 전역변수로
        // 함수가 호출할 때마다 보내지는 메세지에 해당. sender는 그 메세지(msg)를 
        // 초기화한 사람(이 함수를 호출하는 사람).
        // address(this) 에서 this 는 이 token farm smart contract 자체에 해당.
        // 그 this를 address 타입으로 변환한 것이 address(this)
        // amount는 investor의 지갑에서 smart contract로 전송할 토큰 양
        daiToken.transferFrom(msg.sender, address(this), _amount);
    }

    // 2. Unstaking Tokens (Withdraw)
    // 3. Issuing Tokens (이자)

}