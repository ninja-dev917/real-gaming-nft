pragma solidity >=0.4.22 <0.9.0;
import "./DappToken.sol";

contract DappTokenSale {
    address admin;
    DappToken public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokenSold;

    event Sell(address _to, uint256 _amount);

    constructor(DappToken _tokenContract, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenPrice = _tokenPrice;
        tokenSold = 0;
        tokenContract = _tokenContract;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyToken(uint256 _amount) public payable {
        require(msg.value == multiply(_amount, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _amount);
        require(tokenContract.transfer(msg.sender, _amount));

        tokenSold += _amount;
        emit Sell(msg.sender, _amount);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));

        // Just transfer the balance to the admin
        // admin.transfer(address(this).balance);
    }
}