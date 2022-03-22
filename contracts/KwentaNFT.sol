// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@rari-capital/solmate/src/tokens/ERC1155.sol";

error InvalidTier(uint256 tier);
error CallerIsNotOwner(address owner);
error MintIsDisabled(bool isMintingDisabled);
error HasDistributed(bool hdt0, bool hdt1, bool hdt2, bool hdt3);

contract KwentaNFT is ERC1155 {
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

            // An array can't have a total length
            // larger than the max uint256 value.
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

    // 7. Contract owner: Should be able to disable minting
    function disableMint() public payable {
        if (owner != msg.sender) revert CallerIsNotOwner(owner);
        isMintDisabled = true;
    }
}
