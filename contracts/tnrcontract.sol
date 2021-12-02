// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



// ░██████╗░░█████╗░░██████╗░██████╗███████╗██████╗░  ░██████╗████████╗██╗░░░██╗██████╗░██╗░█████╗░██╗░██████╗
// ██╔════╝░██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗  ██╔════╝╚══██╔══╝██║░░░██║██╔══██╗██║██╔══██╗╚█║██╔════╝
// ██║░░██╗░███████║╚█████╗░╚█████╗░█████╗░░██║░░██║  ╚█████╗░░░░██║░░░██║░░░██║██║░░██║██║██║░░██║░╚╝╚█████╗░
// ██║░░╚██╗██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░██║░░██║  ░╚═══██╗░░░██║░░░██║░░░██║██║░░██║██║██║░░██║░░░░╚═══██╗
// ╚██████╔╝██║░░██║██████╔╝██████╔╝███████╗██████╔╝  ██████╔╝░░░██║░░░╚██████╔╝██████╔╝██║╚█████╔╝░░░██████╔╝
// ░╚═════╝░╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░  ╚═════╝░░░░╚═╝░░░░╚═════╝░╚═════╝░╚═╝░╚════╝░░░░╚═════╝░
// weregassed@gmail.com


contract TheNewResistance is Context, ERC721Enumerable, ERC721Burnable, Ownable {
    uint internal constant MAX_MINTS_PER_TRANSACTION = 20;
    uint internal constant TOKEN_LIMIT = 10000;

    uint private nonce = 0;
    uint[TOKEN_LIMIT] private indices;
    uint private numTokens = 0;
    
    uint256 internal _mintPrice = 0;
    
    address payable internal devteam = payable(0x1511637D85E85e4EF4c162844A0a3D4D4fe2e5a4); 
    address payable internal A = payable(0x630cE4d80eF8712DFFd1A38fe390683b675Ab48a);
    address payable internal B = payable(0xc4c746E4783E2eCd4610dC798874a8a765a724C0);

    string internal _baseTokenURI;
    bool internal saleStarted = false;
    bool internal URISet = false;
    uint internal devSupplyAwarded = 0;

    /**
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(string memory name, string memory symbol,string memory baseTokenURI) ERC721(name, symbol) {
         _baseTokenURI = baseTokenURI;
        //dont call awardDevs() here, initial supply here, too much gas for one transaction
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }   
    
    /**
    * Can only be called twice. Gives 40 total Tokens to devs for giveaways, marketing purposes and team members.
    */
    function ToDevs() external onlyOwner {
        require(saleStarted == false,"Sale started");
        require(devSupplyAwarded < 2,"Dev supply already awarded");
        uint i;
        uint id;

        for(i = 0; i < 20; i++){
            id = randomIndex();
            _mint(devteam, id);
            numTokens = numTokens +1;
        }

        devSupplyAwarded = devSupplyAwarded+1;
    } 
    function randomIndex() internal returns (uint) {
        uint totalSize = TOKEN_LIMIT - numTokens;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;

        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }

        // Move last value to selected position
        if (indices[totalSize - 1] == 0) {
            // Array position not initialized, so use position
            indices[index] = totalSize - 1;
        } else {
            // Array position holds a value so use that
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }
    
    /**
     * @dev Creates a new token. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     * 
     */
    function mint(address to, uint amount) external payable{
        //check sale start
        require(saleStarted == true, "Sale has not started yet");

        //only 10000 Tokens
        require(numTokens < TOKEN_LIMIT, "No Tokens left in the nest");

        //mint at least one
        require(amount > 0, "Must mint at least one");

        //32 max per transaction
        require(amount <= MAX_MINTS_PER_TRANSACTION, "Trying to mint too many");

        //dont overmint
        require(amount <= TOKEN_LIMIT-numTokens,"Not enough Tokens left to mint");

        //check payment
        require(msg.value >= _mintPrice * amount, "msg.value too low");

        uint id;
        uint i;

        for(i = 0; i < amount; i++){
            id = randomIndex();
            _mint(to, id);
            numTokens = numTokens + 1;
        }

    }


    function withdrawFunds() external virtual {
        uint256 halfBalance = address(this).balance / 2;
        uint256 HalfOfHalfBalance = halfBalance / 2;
        devteam.transfer(halfBalance);
        A.transfer(HalfOfHalfBalance);
        B.transfer(HalfOfHalfBalance);
    }

    /**
    * Devs cant change URI after the sale begins 
    */
    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        require(saleStarted == false,"Can't change metadata after the sale has started");
        _baseTokenURI = baseTokenURI;
        URISet = true;
    }

    /**
    * Start the sale (cant be stopped later)
    */
    function startSale(uint256 mintPrice) external virtual onlyOwner {
        require(saleStarted == false,"Sale has already started");
        require(URISet == true, "URI not set");
        require(mintPrice > 0.06 ether,"Price too low");
        _mintPrice = mintPrice;
        saleStarted = true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getAmountMinted() external view returns (uint256) {
        return numTokens;
    }

    function getMaxSupply() external pure returns (uint256) {
        return TOKEN_LIMIT;
    }

    function getMintPrice() external view returns (uint256) {
        return _mintPrice;
    }

    function hasSaleStarted() external view returns (bool) {
        return saleStarted;
    }

}