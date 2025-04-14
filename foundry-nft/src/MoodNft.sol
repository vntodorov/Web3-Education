// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    //errors
    error NFTStateNft__CantFlipNFTStateIfNotOwner();
    error ERC721Metadata__URI_QueryFor_NonExistentToken();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum NFTState {
        HAPPY,
        SAD
    }

    event CreatedNFT(uint256 indexed tokenId);

    mapping(uint256 => NFTState) private s_tokenIdToNFTState;

    constructor(
        string memory sadSvgImageUri,
        string memory happySvgImageUri
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter += 1;
    }

    function flipMood(uint256 tokenId) public {
        if (
            getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender
        ) {
            revert NFTStateNft__CantFlipNFTStateIfNotOwner();
        }

        if (s_tokenIdToNFTState[tokenId] == NFTState.HAPPY) {
            s_tokenIdToNFTState[tokenId] = NFTState.SAD;
        } else {
            s_tokenIdToNFTState[tokenId] = NFTState.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        string memory imageURI = s_happySvgImageUri;
        string memory mood = "Happy";
        if (s_tokenIdToNFTState[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgImageUri;
            mood = "Sad";
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], ',
                                '"mood":"',
                                mood,
                                '", ',
                                '"image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getTokenMood(uint256 tokenId) public view returns (string memory) {
        if (s_tokenIdToNFTState[tokenId] == NFTState.SAD) {
            return "SAD";
        } else {
            return "HAPPY";
        }
    }
}
