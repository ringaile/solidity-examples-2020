pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Allowance is Ownable{
    
    using SafeMath for uint;
    
    event AllowanceChanged (address _forWho, address _fromWhom, uint indexed _oldAmount, uint indexed _newAmount);

    mapping(address => uint) public allowance;
    
    modifier ownerOrAllowed(uint _amount){
        require(msg.sender == owner() || allowance[msg.sender] >  _amount, "You are not allowed");
        _;
    }
    
    function renounceOwnership() public override onlyOwner{
        revert("Can't renounce ownership here.");
    }
    
    function addAlowance(address _who, uint _amount) public onlyOwner{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }
    
    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}

contract SimpleWallet is Allowance{
    
    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint amount);
    
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "There are not enough funds in the contract");
        if(msg.sender != owner()){
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }
    
    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}
