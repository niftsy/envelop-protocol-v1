// SPDX-License-Identifier: MIT
// ENVELOP protocol for NFT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//v0.0.1
contract EnvelopwNFT1155 is ERC1155Supply, Ownable {
    using Strings for uint256;
    using Strings for uint160;
    
    address public wrapperMinter;
    string  public baseurl;
    
    constructor(
        string memory name_,
        string memory symbol_,
        string memory _baseurl
    ) 
        ERC1155(_baseurl)  
    {
        wrapperMinter = msg.sender;
        baseurl = string(
            abi.encodePacked(
                _baseurl,
                block.chainid.toString(),
                "/",
                uint160(address(this)).toHexString(),
                "/"
            )
        );
        _setURI(baseurl);

    }

    function mint(address _to, uint256 _tokenId, uint256 _amount) external {
        require(wrapperMinter == msg.sender, "Trusted address only");
        _mint(_to, _tokenId, _amount, "");
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(address _from, uint256 _tokenId, uint256 _amount) public virtual {
        require(wrapperMinter == msg.sender, "Trusted address only");
        /*require(
            _from == _msgSender() || isApprovedForAll(_from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );*/
        _burn(_from, _tokenId, _amount);
    }

    function setMinterStatus(address _minter) external onlyOwner {
        wrapperMinter = _minter;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(true, "ERC1155Pausable: token transfer while paused");
    }
    
    
    function uri(uint256 _tokenID) public view virtual override 
        returns (string memory) 
    {
        return string(abi.encodePacked(
            ERC1155.uri(0),
            _tokenID.toString()
            )
        );
    }

    /**
     * @dev Function returns tokenURI of **underline original token** 
     *
     * @param _tokenId id of protocol token (new wrapped token)
     */
    // function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    //     NFT storage nft = wrappedTokens[_tokenId];
    //     if (nft.tokenContract != address(0)) {
    //         return IERC721Metadata(nft.tokenContract).tokenURI(nft.tokenId);
    //     } else {
    //         return ERC721.tokenURI(_tokenId);
    //     }    
    // }

    
}
