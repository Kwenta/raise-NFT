// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

error HasDistributed(bool hasDistributed);

// 1. Should be one contract
contract KwentaNFT is ERC1155, AccessControl, ERC1155Supply {
    event KwentaNFTsDistributed();
    event MintingDisabled();
    event MintingEnabled();

    error DistributeToMultipleAccounts(
        address[] to,
        uint256[] tokenIds,
        uint256[] amounts,
        TokenTier[] tiers
    );

    //
    struct Recipient {
        address account;
        TokenTier[] tokens;
    }

    struct TokenTier {
        uint256 tokenId;
        bytes32 tier;
    }

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

    // 4. Tiers should be stored in blocks of token ids (Tier 0: 1-100, Tier 1:
    //    101-150, etc.)
    mapping(uint256 => TokenTier) tier0s;
    mapping(uint256 => TokenTier) tier1s;
    mapping(uint256 => TokenTier) tier2s;
    mapping(uint256 => TokenTier) tier3s;
    // 5. Leave open how many token ids go into each tier
    mapping(address => Recipient) recipients;

    constructor(string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
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

    // 8. There should not be a public mint function
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev // todo: finish this function!!
     * 6. Should be allowed to do a one-time distribution, full control over
     *  minting function.
     *
     * 10. Make sure to set which token ids sequentially go into the 4 tiers,
     *     etc.
     *
     *    To achieve this, we're going to require that the `recipients` and
     *    `tokenIds` inputs are each arrays of size 1 x 4 where each subarray in
     *    the array maps to a specific tier.
     *
     *    Example:  address[][] _recipients = [
     *                                         tier0Recipients,
     *                                         tier1Recipients,
     *                                         tier2Recipients,
     *                                         tier3Recipients
     *                                        ]
     *             uint256[][] _tokenIds = [
     *                                      tier0TokenIds,
     *                                      tier1TokenIds,
     *                                      tier2TokenIds,
     *                                      tier3TokenIds
     *                                     ]
     */
    function distributeNFTs(
        address _account,
        address[][] memory _recipients,
        uint256[][] memory _tokenIds,
        bytes memory _data
    ) public onlyRole(MINTER_ROLE) {
        if (hasDistributed == false) {
            revert HasDistributed({hasDistributed: hasDistributed});
        }

        if (_to.length == 1 && _tokenIds.length == 1 && _amounts.length == 1) {
            revert DistributeToMultipleAccounts({
                to: _to,
                tokenIds: _tokenIds,
                amounts: _amounts,
                tiers: _tiers
            });
        }
        // todo: finish this function!!
        // 7. Should be able to mint in large batches
        if (_to.length > 1 && _tokenIds.length > 1 && _amounts.length > 1) {
            // todo Figure out how tf do you handle batch mints to specific
            //      accounts!! ༼ つ ◕_◕ ༽つ
            for (uint256 i = 0; i < _to.length; i++) {
                if (recipients[_to[i]].account.length > 1) {
                    Recipient recipient_ = recipients[_to[i]];

                    TokenTier memory tokenTier = TokenTier(
                        _tokenIds[i],
                        _tiers[i]
                    );

                    // 4. Tiers should be stored in blocks of token ids (Tier 0:
                    //    1-100, Tier 1: 101-150, etc.)
                    if (tokenTier.tier == TIER_0) {
                        tier0s[tokenIds[i]];
                    }

                    if (tokenTier.tier == TIER_1) {
                        tier1s[tokenIds[i]];
                    }

                    if (tokenTier.tier == TIER_2) {
                        tier2s[tokenIds[i]];
                    }

                    if (tokenTier.tier == TIER_3) {
                        tier3s[tokenIds[i]];
                    }

                    recipient_.tokens.push(tokenTier);

                    _mintBatch(_to[i], _tokenIds, _amounts, _data);
                } else {}

                TokenTier memory tokenTier_;
            }
        }
    }

    // todo: finish this function!!
    function setTier(
        address[] memory accounts,
        uint256[] memory tokenIds,
        bytes32[] memory tiers
    ) internal {
        if (accounts.length == 1) {
            Tier memory tier = Tier(accounts[0], tokenIds[0], tiers[0]);

            tiers[accounts[0]] = tier;
        }
        if (accounts.length > 1) {}
    }

    function getTier(address account, uint256 tokenId)
        public
        view
        returns (TokenTier memory tokenTier)
    {
        return tier;
    }

    // todo: finish this function!!
    // 7. Contract owner: Should be able to disable minting
    function disableMint() public onlyRole(DEFAULT_ADMIN_ROLE) {}

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
