pragma solidity >0.5.0 <0.6.0;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

interface ERC20Interface {
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract Enigma is ERC20Interface {

    using SafeMath for uint;
    uint public decimals = 8;
    struct Member {
        uint256 id;
        address memAddress;
        uint256 tokenBalance;
    }
    address public owner;
    string public name ;
    uint public  totalSupply ;
    uint256 public totalMembers = 0;
   
    mapping (address => Member ) members;

    mapping (address => mapping (address => uint256) ) allowed;

    constructor (uint256 _totalSupply, string memory _name ) public {
        owner = msg.sender;
        name = _name;
        totalSupply = _totalSupply;
        members[msg.sender].memAddress = msg.sender;
        members[msg.sender].tokenBalance = _totalSupply;
        members[msg.sender].id = totalMembers.add(1);
        incMemberCount();
    }
   
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
   
    function incMemberCount() private {
        totalMembers = totalMembers.add(1);
    }
   
    function addMembers(address newMember, uint tokens) public onlyOwner payable returns(bool) {
        require(tokens <= balanceOf(msg.sender), "Owner Doesn't have any Token left to Distribute");
        require(members[newMember].id == 0, "Member Already Exists..!");
        members[newMember].memAddress = newMember;
        members[owner].tokenBalance -= tokens;
        members[newMember].tokenBalance = tokens;
        members[newMember].id = totalMembers + 1;
        incMemberCount();
        return true;
    }
   
    function transfer(address to, uint tokens) public returns (bool){
        require(members[msg.sender].tokenBalance >= tokens,"Balance Low");
        require(members[msg.sender].id !=0, "You are not part of Enigma Ecosystem..!");
        require(members[to].id !=0, "You are not part of Enigma Ecosystem..!");
        members[msg.sender].tokenBalance = members[msg.sender].tokenBalance.sub(tokens);
        members[to].tokenBalance = members[to].tokenBalance.add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true ;
    }

    function balanceOf(address _address ) public view returns (uint256 balance){
        require(members[_address].id != 0, "You are not Part of my Ecosystem");
        balance = members[_address].tokenBalance;
        return balance;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256){
        return allowed[msg.sender][spender];
    }
       
    function approve(address spender, uint tokens) public returns (bool){
        require(members[spender].id != 0, "Spender is not Part of Enigma Ecosystem");
        require(members[msg.sender].id != 0, "You are not Part of Enigma Ecosystem");
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(tokens);
        emit Approval (msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool){
        require(members[from].id != 0, "You are not Part of Enigma Ecosystem");
        require(members[to].id != 0, "You are not Part of Enigma Ecosystem");
        require(members[msg.sender].id != 0, "You are not Part of Enigma Ecosystem");
        require(members[from].tokenBalance >= tokens,"Balance Low");
        require(allowed[from][msg.sender] >= tokens,"You are exceeding your Spending Limit");
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        members[from].tokenBalance = members[from].tokenBalance.sub(tokens);
        members[to].tokenBalance = members[to].tokenBalance.add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}
