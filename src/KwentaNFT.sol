// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

error HasDistributed(bool hasDistributed);
error InequalInputArrays(uint256 recipientsLength, uint256 tokenIdsLength);
error MintingIsDisabled(
    address account,
    uint256 id,
    uint256 amount,
    bytes data
);

// 1. Should be one contract
contract KwentaNFT is ERC1155, AccessControl, ERC1155Supply {
    event Distributed();
    event MintingDisabled();
    // event MintingEnabled();

    struct Recipient {
        address account;
        TieredToken[] tieredTokens;
    }

    struct TieredToken {
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
    bool isMintingDisabled;

    // 5. Leave open how many token ids go into each tier
    mapping(address => Recipient) recipients;
    // Used to fetch the tier for a tokenId.
    mapping(uint256 => bytes32) tieredTokens;

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
     *
     * 10. Make sure to set which token ids sequentially go into the 4 tiers,
     *     etc.
     *
     *    To achieve this, we're going to require that the `recipients` and
     *    `tokenIds` inputs are each arrays of size 1 x 4 where each subarray in
     *    the array maps to a specific tier.
     *
     * Example:  address[][] _recipients = [
     *                                      tier0Recipients,
     *                                      tier1Recipients,
     *                                      tier2Recipients,
     *                                      tier3Recipients
     *                                     ]
     *           uint256[][] _tokenIds = [
     *                                    tier0TokenIds,
     *                                    tier1TokenIds,
     *                                    tier2TokenIds,
     *                                    tier3TokenIds
     *                                   ]
     */
    function distribute(
        address[][] calldata _recipients,
        uint256[][] calldata _tokenIds
    ) external onlyRole(MINTER_ROLE) {
        if (hasDistributed == false) {
            revert HasDistributed({hasDistributed: hasDistributed});
        }

        if (_tokenIds.length != _recipients.length) {
            revert InequalInputArrays(_recipients.length, _tokenIds.length);
        }

        // todo: Need to check:
        //         1. how much gas this consumes
        //         2. whether we can turn this function to an external function
        //            to save on gas

        //  4. Tiers should be stored in blocks of token ids (Tier 0: 1-100,
        //     Tier 1: 101-150, etc.)
        // If TIER_0
        if (abi.encodePacked(_recipients[0][0]).length == 0) {
            for (uint256 i; i < _recipients[0].length; i++) {
                TieredToken memory tieredToken = TieredToken(
                    _tokenIds[0][i],
                    TIER_0
                );

                // If there is no `Recipient` found in mapping
                if (
                    (abi
                        .encodePacked(recipients[_recipients[0][i]].account)
                        .length == 0)
                ) {
                    TieredToken[] memory tieredToken_;
                    Recipient memory recipient_ = Recipient(
                        _recipients[0][i],
                        tieredToken_
                    );

                    recipient_ = recipients[_recipients[0][i]];

                    // Store recipient
                    recipients[_recipients[0][i]] = recipient_;

                    // Mint token to recipient
                    bytes memory TIER_0_ = abi.encodePacked(TIER_0);
                    _mint(_recipients[0][i], _tokenIds[0][i], 1, TIER_0_);
                } else {
                    // Fetch `recipient_` and add new `tieredToken`
                    recipients[_recipients[0][i]].tieredTokens.push(
                        tieredToken
                    );

                    // Mint token to recipient
                    bytes memory TIER_0_ = abi.encodePacked(TIER_0);
                    _mint(_recipients[0][i], _tokenIds[0][i], 1, TIER_0_);
                }
            }
        }

        // If TIER_1
        if (abi.encodePacked(_recipients[1][0]).length == 0) {
            for (uint256 i; i < _recipients[1].length; i++) {
                TieredToken memory tieredToken = TieredToken(
                    _tokenIds[1][i],
                    TIER_1
                );

                // If there is no `Recipient` found in mapping
                if (
                    (abi
                        .encodePacked(recipients[_recipients[1][i]].account)
                        .length == 0)
                ) {
                    TieredToken[] memory tieredToken_;
                    Recipient memory recipient_ = Recipient(
                        _recipients[1][i],
                        tieredToken_
                    );

                    recipient_ = recipients[_recipients[1][i]];

                    // Store recipient
                    recipients[_recipients[1][i]] = recipient_;

                    // Mint token to recipient
                    bytes memory TIER_1_ = abi.encodePacked(TIER_1);
                    _mint(_recipients[1][i], _tokenIds[1][i], 1, TIER_1_);
                } else {
                    // Fetch `recipient_` and add new `tieredToken`
                    recipients[_recipients[1][i]].tieredTokens.push(
                        tieredToken
                    );

                    // Mint token to recipient
                    bytes memory TIER_1_ = abi.encodePacked(TIER_1);
                    _mint(_recipients[1][i], _tokenIds[1][i], 1, TIER_1_);
                }
            }
        }

        // If TIER_2
        if (abi.encodePacked(_recipients[2][0]).length == 0) {
            for (uint256 i; i < _recipients[2].length; i++) {
                TieredToken memory tieredToken = TieredToken(
                    _tokenIds[2][i],
                    TIER_2
                );

                // If there is no `Recipient` found in mapping
                if (
                    (abi
                        .encodePacked(recipients[_recipients[2][i]].account)
                        .length == 0)
                ) {
                    TieredToken[] memory tieredToken_;
                    Recipient memory recipient_ = Recipient(
                        _recipients[2][i],
                        tieredToken_
                    );

                    recipient_ = recipients[_recipients[2][i]];

                    // Store recipient
                    recipients[_recipients[2][i]] = recipient_;

                    // Mint token to recipient
                    bytes memory TIER_2_ = abi.encodePacked(TIER_2);
                    _mint(_recipients[2][i], _tokenIds[2][i], 1, TIER_2_);
                } else {
                    // Fetch `recipient_` and add new `tieredToken`
                    recipients[_recipients[2][i]].tieredTokens.push(
                        tieredToken
                    );

                    // Mint token to recipient
                    bytes memory TIER_2_ = abi.encodePacked(TIER_2);
                    _mint(_recipients[2][i], _tokenIds[2][i], 1, TIER_2_);
                }
            }
        }

        // If TIER_3
        if (abi.encodePacked(_recipients[3][0]).length == 0) {
            for (uint256 i; i < _recipients[3].length; i++) {
                TieredToken memory tieredToken = TieredToken(
                    _tokenIds[3][i],
                    TIER_3
                );

                // If there is no `Recipient` found in mapping
                if (
                    (abi
                        .encodePacked(recipients[_recipients[3][i]].account)
                        .length == 0)
                ) {
                    TieredToken[] memory tieredToken_;
                    Recipient memory recipient_ = Recipient(
                        _recipients[3][i],
                        tieredToken_
                    );

                    recipient_ = recipients[_recipients[3][i]];

                    // Store recipient
                    recipients[_recipients[3][i]] = recipient_;

                    // Mint token to recipient
                    bytes memory TIER_3_ = abi.encodePacked(TIER_3);
                    _mint(_recipients[3][i], _tokenIds[3][i], 1, TIER_3_);
                } else {
                    // Fetch `recipient_` and add new `tieredToken`
                    recipients[_recipients[3][i]].tieredTokens.push(
                        tieredToken
                    );

                    // Mint token to recipient
                    bytes memory TIER_3_ = abi.encodePacked(TIER_3);
                    _mint(_recipients[3][i], _tokenIds[3][i], 1, TIER_3_);
                }
            }
        }
    }

    function getTierByID(uint256 tokenId) public view returns (bytes32 tier) {
        tier = tieredTokens[tokenId];
        return tier;
    }

    // 7. Contract owner: Should be able to disable minting
    function disableMint() public onlyRole(DEFAULT_ADMIN_ROLE) {
        isMintingDisabled = true;
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
