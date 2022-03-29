// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@rari-capital/solmate/src/tokens/ERC1155.sol";

error InvalidTier(uint256 tier);
error CallerIsNotOwner(address owner);
error MintIsDisabled(bool isMintingDisabled);
error HasDistributed(bool hdt0, bool hdt1, bool hdt2, bool hdt3);

contract RaiseNFT is ERC1155 {
    using Strings for uint256;

    // public state vars
    address public immutable owner;
    bool public hdt0; // hdt0 = hasDistributedTier0
    bool public hdt1; // hdt1 = hasDistributedTier1
    bool public hdt2; // hdt2 = hasDistributedTier2
    bool public hdt3; // hdt3 = hasDistributedTier3
    bool public isMintDisabled;
    // private state vars
    string private baseURI;

    mapping(uint256 => uint256) tokenIdToTier;

    constructor(string memory _baseURI) ERC1155() {
        baseURI = _baseURI;
        owner = msg.sender;
    }

    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    baseURI,
                    getTierByTokenID(tokenId).toString(),
                    ".json"
                )
            );
    }

    function getTierByTokenID(uint256 tokenId)
        public
        view
        returns (uint256 tierId)
    {
        return tokenIdToTier[tokenId];
    }

    function distribute(
        address[] calldata _to,
        uint256[] calldata _tokenIds,
        uint256 _tier
    ) external payable {
        if (_tier > 3) revert InvalidTier(_tier);
        if (isMintDisabled) revert MintIsDisabled(isMintDisabled);
        if (owner != msg.sender) revert CallerIsNotOwner(owner);
        if (hdt0 && hdt1 && hdt2 && hdt3)
            revert HasDistributed(hdt0, hdt1, hdt2, hdt3);

        address to;
        uint256 tokenId;

        for (uint256 i = 0; i < _tokenIds.length; ) {
            to = _to[i];
            tokenId = _tokenIds[i];
            tokenIdToTier[tokenId] = _tier;

            _mint(to, _tier, 1, "");

            unchecked {
                ++i;
            }
        }

        setHasDistributedTier(true, _tier);
    }

    function setHasDistributedTier(bool _value, uint256 _tier) internal {
        if (_tier == 0) hdt0 = _value;
        if (_tier == 1) hdt1 = _value;
        if (_tier == 2) hdt2 = _value;
        if (_tier == 3) hdt3 = _value;
    }

    function disableMint() public payable {
        if (owner != msg.sender) revert CallerIsNotOwner(owner);
        isMintDisabled = true;
    }
}
