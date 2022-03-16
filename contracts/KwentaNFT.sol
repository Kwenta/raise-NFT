// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "./ERC1155.sol";

error HasDistributed(bool hasDistributed);
error NotEnoughTiers(uint256 tiersLength);
error MintIsDisabled(bool isMintingDisabled);
error CallerIsNotOwner(address owner);

// 1. Should be one contract
contract KwentaNFT is ERC1155 {
    event Distributed();
    event MintDisabled();

    // state vars
    address public owner;
    bool public hasDistributed;
    bool public isMintDisabled;

    constructor(string memory uri) ERC1155(uri) {
        owner = msg.sender;
    }

    // 8. There should not be a public mint function
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        _mint(account, id, amount, data);
    }

    /**
     * 6. Should be allowed to do a one-time distribution, full control over
     *  minting function.
     */
    function distribute(address[] calldata _to) external payable {
        if (msg.sender != owner) revert CallerIsNotOwner(owner);
        if (hasDistributed) revert HasDistributed(hasDistributed);
        if (isMintDisabled) revert MintIsDisabled(isMintDisabled);

        uint256 numIds = 207;
        address to;
        uint256 tier0 = 0;
        uint256 tier1 = 1;
        uint256 tier2 = 2;
        uint256 tier3 = 3;

        for (uint256 i = 1; i < numIds; ) {
            to = _to[i];

            if (i < 101) mintByTier(to, tier0);
            if (i > 100 && i < 151) mintByTier(to, tier1);
            if (i > 150 && i < 201) mintByTier(to, tier2);
            if (i > 200) mintByTier(to, tier3);

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        hasDistributed = true;
    }

    function mintByTier(address _to, uint256 _tier) internal {
        uint256 quantity = 1;

        if (_tier == 0) _mint(_to, _tier, quantity, "");
        if (_tier == 1) _mint(_to, _tier, quantity, "");
        if (_tier == 2) _mint(_to, _tier, quantity, "");
        if (_tier == 3) _mint(_to, _tier, quantity, "");
    }

    function getTierByTokenID(uint256 tokenId) public pure returns (uint256) {
        if (tokenId < 101) return 0;
        if (tokenId > 100 && tokenId < 151) return 1;
        if (tokenId > 150 && tokenId < 201) return 2;
        if (tokenId > 200) return 3;
    }

    // 7. Contract owner: Should be able to disable minting
    function disableMint() external {
        if (msg.sender != owner) revert CallerIsNotOwner(owner);
        isMintDisabled = true;
    }
}