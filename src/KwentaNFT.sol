// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

error HasDistributed(bool hasDistributed);
error NotEnoughTiers(uint256 tiersLength);
error MintIsDisabled(bool isMintingDisabled);
error MisorderedTiers(
    uint256 tier0,
    uint256 tier1,
    uint256 tier2,
    uint256 tier3
);

// 1. Should be one contract
contract KwentaNFT is ERC1155, AccessControl, ERC1155Supply {
    event Distributed();
    event MintDisabled();

    // Role state vars
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // Tier state vars
    bytes32 public constant TIER_0 = keccak256("TIER_0");
    bytes32 public constant TIER_1 = keccak256("TIER_1");
    bytes32 public constant TIER_2 = keccak256("TIER_2");
    bytes32 public constant TIER_3 = keccak256("TIER_3");

    // Other state vars
    bool hasDistributed;
    bool isMintDisabled;

    constructor(string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newUri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newUri);
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
    function distribute(address[] calldata _to, uint256[] calldata _tiers)
        external
        payable
        onlyRole(MINTER_ROLE)
    {
        if (!hasDistributed) revert HasDistributed(hasDistributed);
        if (isMintDisabled) revert MintIsDisabled(isMintDisabled);
        if (_tiers.length != 4) revert NotEnoughTiers(_tiers.length);
        if (
            _tiers[0] != 0 && _tiers[1] != 1 && _tiers[2] != 2 && _tiers[3] != 3
        ) revert MisorderedTiers(_tiers[0], _tiers[1], _tiers[2], _tiers[3]);

        //  4. Tiers should be stored in blocks of token ids (Tier 0: 1-100,
        //     Tier 1: 101-150, etc.)
        for (uint256 i = 1; i < 207; i++) {
            if (i < 101) mintByTier(_to[i], _tiers[0]);
            if (i > 100 && i < 151) mintByTier(_to[i], _tiers[1]);
            if (i > 150 && i < 201) mintByTier(_to[i], _tiers[2]);
            if (i > 200) mintByTier(_to[i], _tiers[3]);
        }

        hasDistributed = true;
    }

    function mintByTier(address _to, uint256 _tier) internal {
        if (_tier == 0) {
            bytes memory tier = abi.encodePacked(_tier);
            _mint(_to, _tier, 1, tier);
        }
        if (_tier == 1) {
            bytes memory tier = abi.encodePacked(_tier);
            _mint(_to, _tier, 1, tier);
        }
        if (_tier == 2) {
            bytes memory tier = abi.encodePacked(_tier);
            _mint(_to, _tier, 1, tier);
        }
        if (_tier == 3) {
            bytes memory tier = abi.encodePacked(_tier);
            _mint(_to, _tier, 1, tier);
        }
    }

    function getTokenIDTier(uint256 tokenId)
        public
        view
        returns (bytes32 tier)
    {
        if (tokenId < 101) return TIER_0;
        if (tokenId > 100 && tokenId < 151) return TIER_1;
        if (tokenId > 150 && tokenId < 201) return TIER_2;
        if (tokenId > 200) return TIER_3;
    }

    // 7. Contract owner: Should be able to disable minting
    function disableMint() external onlyRole(MINTER_ROLE) {
        isMintDisabled = true;
    }

    // Function override required by Solidity.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // Function override required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
