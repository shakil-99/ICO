// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// ERC20 Standard interface
interface IERC20{
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to,uint tokens) external returns(bool);
    function allowance(address tokenOwner, address spender) external view returns (uint);
    function approve(address spender, uint tokens) external returns(bool);
    function transferFrom(address from, address to,uint amount) external returns(bool);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed owner,address indexed spender, uint tokens);
}

// using safemath library for operation
library Safemath{
    function add(uint a, uint b) internal pure returns(uint c){
        c = a + b;
        require(c>=a);
    }
    function sub(uint a, uint b) internal pure returns(uint c){
        require(b <= a);
        c = a-b;
    }
    function mul( uint a, uint b) internal pure returns(uint c){
        c = a*b;
        require(a==0||c/a==b);
    }
    function div( uint a, uint b) internal pure returns(uint c){
        require(b>0);
        c = a/b;
    }
}

contract ICO is IERC20{
    using Safemath for uint;

    string public name;
    string public symbol;
    uint public decimal;
    uint public bonusEnds;
    uint public icoEnds;
    uint public icoStarts;
    uint public allContributers;
    uint8 private phase=1;
    uint private price;
    uint allTokens;
    address payable admin = payable(msg.sender);
    mapping(address=>uint) public balances;
    mapping(address=>mapping(address=>uint)) allowed;
    mapping(address=>bool)whiteList;
    

    constructor () {
        name = "Yudiz Coin";
        decimal = 0;
        symbol ="YDC";
        icoStarts = block.timestamp;
        bonusEnds = block.timestamp + 2 weeks;
        icoEnds = block.timestamp + 4 weeks;
        allTokens = 100000000000000000000 * 100; // Equal to 100 Ether * 100YDC
        balances[msg.sender] = allTokens;
    }

   
     function buyToken() public payable{
        uint tokens;
        if (block.timestamp <= bonusEnds){
            tokens = msg.value.mul(25); // 25% bouns
        } else{
            tokens = msg.value.mul(100); // no bonus
        }
        tokens = msg.value.mul(100); //100 token == 1 Ether
        allTokens = allTokens + tokens;
        emit Transfer(address(0),msg.sender,tokens);

        allContributers ++;
    }

    function totalSupply() public override view returns(uint){
        return allTokens;
    }
    
    function balanceOf(address owner) external override view returns(uint256){
        return balances[owner];
    }

    function transfer(address to, uint tokens) public override returns(bool success){
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 tokens)public override  returns(bool){
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to , tokens);
        return true;
    }

    function approve (address spender, uint256 tokens) external override returns(bool){
        allowed[msg.sender] [spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }


    function Mybalance() public view returns(uint){
        return (balances[msg.sender]);
    }

    function MyAddress() public view returns(address){
        address myAdr = msg.sender;
        return myAdr;
    }

    function endSale() public payable{
        require(msg.sender == admin);
        admin.transfer(address(this).balance);
    }

   
}