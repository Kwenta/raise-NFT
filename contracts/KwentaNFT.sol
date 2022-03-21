// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@rari-capital/solmate/src/tokens/ERC1155.sol";

error CallerIsNotOwner(address owner);
error TokenIdOutOfRange(uint256 tokenId);
error HasDistributed(bool hasDistributed);
error MintIsDisabled(bool isMintingDisabled);

contract KwentaNFT is ERC1155 {
    using Strings for uint256;

    // public state vars
    address public immutable owner;
    bool public hasDistributed;
    bool public isMintDisabled;
    // private state vars
    string private baseURI;

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
        pure
        returns (uint256 tierId)
    {
        if (tokenId < 101) return 0;
        if (tokenId > 100 && tokenId < 151) return 1;
        if (tokenId > 150 && tokenId < 201) return 2;
        if (tokenId > 200 && tokenId < 207) return 3;
        if (tokenId > 206) revert TokenIdOutOfRange(tokenId);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        _mint(to, id, amount, data);
    }

    function batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        _batchMint(to, ids, amounts, data);
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public virtual {
        _burn(from, id, amount);
    }

    function batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual {
        _batchBurn(from, ids, amounts);
    }

    function distribute(address[] calldata _to) external payable {
        if (msg.sender != owner) revert CallerIsNotOwner(owner);
        if (hasDistributed) revert HasDistributed(hasDistributed);
        if (isMintDisabled) revert MintIsDisabled(isMintDisabled);

        address to;
        uint256 tier0 = 0;
        uint256 tier1 = 1;
        uint256 tier2 = 2;
        uint256 tier3 = 3;
        uint256 numIds = 206;

        for (uint256 i = 1; i < numIds; ) {
            to = _to[i - 1];

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

    // 7. Contract owner: Should be able to disable minting
    function disableMint() public {
        if (msg.sender != owner) revert CallerIsNotOwner(owner);
        isMintDisabled = true;
    }
}
