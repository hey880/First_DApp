pragma solidity >= 0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    // All code goes here...
    string public name = "Dapp Token Farm";
    address public owner;
    DappToken public dappToken;
    DaiToken public daiToken;

// key로 address를 넣으면 현재 investor가 얼마나 staking 한지(value)를 return 하는 
// mapping 타입의 변수
    mapping(address => uint) public stakingBalance;

// 사용자가 staked 했는지 여부를 말해주는 mapping 타입 변수
// 예전에 staking 한 사람한테 중복으로 reward 주면 안되니까
    mapping(address => bool) public hasStaked;

// 현재 stake 상태
    mapping(address => bool) public isStaking;

// 지금까지 staking 한 적이 있는 모든 address들을 추적하는 array
// 나중에 이 staking 한 적 있는 사람들한테 reward를 줘야하기 때문에 이 address들을 추적해야함.
// 누구한테 줘도 되고 아닌지 판단해야 하니까.
    address[] public stakers;

    constructor (DappToken _dappToken, DaiToken _daiToken) public {
        //생성자의 매개변수로 _dappToken, _daiToken을 넣는데 이 변수들의
        //타입은 DappToken, DaiToken, 즉, smart contract 그 자체다.
        //이 매개변수들에 dapptoken address, daitoken address를 패스한다.
        dappToken = _dappToken;
        daiToken = _daiToken;
        //이 address 들은 지역변수이므로 다른 함수들이 접근할 수 있도록 하기
        //위해서 상태변수에 저장합니다.(위 처럼)

        //smart contract deployer
        owner = msg.sender;
    }

    // * Stakes Tokens (Deposit)
    function stakeTokens(uint _amount) public {
        //매개변수는 stake할 토큰의 양
        //smart contract 밖에서 누군가가 호출할 수 있어야 되므로 public으로 선언
        //이건 investor의 지갑에서 이 smart contract로 DAI 토큰을 전송하기 위한 함수

        // Require amount greater than 0
        // require는 solidity의 내장 함수로 require의 조건이 true로 평가될 경우
        // 계속해서 해당 함수가 실행되도록 한다.
        // false로 평가되면 함수가 중단되고 exception을 뱉는다.
        require(_amount > 0, "amount cannot be 0");

        // Transfer Mock Dai tokens to this contract for staking
        // msg.sender는 솔리디티에 내장된 변수, msg는 솔리디티에 내장된 전역변수로
        // 함수가 호출할 때마다 보내지는 메세지에 해당. sender는 그 메세지(msg)를 
        // 초기화한 사람(이 함수를 호출하는 사람).
        // address(this) 에서 this 는 이 token farm smart contract 자체에 해당.
        // 그 this를 address 타입으로 변환한 것이 address(this)
        // amount는 investor의 지갑에서 smart contract로 전송할 토큰 양

        // 이렇게 transfer 하기 전에 investor가 approve(승인) 해야한다.
        daiToken.transferFrom(msg.sender, address(this), _amount);
        
        // Update Staking Balance
        // stakingBalance는 key로 msg.sender를 넣으면 현재 staking 된 amount를 반환하는 mapping 변수
        // 그러니까 아래 수식은 balance+=amount 인거죠, 즉, staking된 금액에 transferFrom으로 가져온 
        // amount를 더한 값을 stakingBalnace에 저장하게 됩니다.
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already
        if (!hasStaked[msg.sender]) {
            //예전에 stake하지 않은(false) 사람이면 staker array에 추가
            stakers.push(msg.sender);
        }

        // Update staking status 
        // staking 상태를 계속 현재 staking 인 상태로 만드는 수식
        isStaking[msg.sender] = true;
        // staking 상태를 계속 staked(예전에 staking한) 상태로 만드는 수식
        hasStaked[msg.sender] = true; 
    }

    // * Unstaking Tokens (Withdraw)
    function unstakeTokens () public {
        // Fetch staking balance
        uint balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer Mock Dai tokens to this contract for staking
        // dai토큰을 이 함수를 호출한 msg.sender에게 보냄
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance
        // msg.sender가 staking 했던 잔액을 모두 인출했기 때문에
        // stakingBalance를 0으로 reset한다.
        stakingBalance[msg.sender] = 0;

        // Udate staking status
        // staking status를 false로 바꿈
        isStaking[msg.sender] = false;
    }

    // * Issuing Tokens (staker들한테 reward 발행)
    // 이 smart contract의 deployer(owner)만 이 함수를 호출할 수 있어야한다.
    function issueTokens() public {
        // smart contract를 deploy한 사람(owner)만 이 함수를 호출할 수 있도록
        // 하는 코드 require~
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers
        for (uint i=0; i<stakers.length; i++) {
            // staker
            address recipient = stakers[i];
            // staker의 balance
            uint balance = stakingBalance[recipient];
            // balance가 0보다 클 때만 reward 줄 것
            // staking 상태의 investor의 balance는 당연히 0보다 클테니까
            if (balance > 0) {
                // staking 1dai 당 1dapp을 rewards
                dappToken.transfer(recipient, balance);
            }
        }
    }
}