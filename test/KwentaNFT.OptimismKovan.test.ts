/* External imports */
import {ethers} from 'hardhat'
import {expect} from 'chai'
import {ContractReceipt, ContractTransaction, utils} from 'ethers'
import {Wallet} from '@ethersproject/wallet'
import {Signer} from '@ethersproject/abstract-signer'
import {JsonRpcProvider} from '@ethersproject/providers'
import 'dotenv/config'

/* Internal imports */
import {KwentaNFT} from '../typechain/KwentaNFT'
import recipientPrivateKeys from '../recipientPrivateKeys.json'


describe(`KwentaNFT (Optimism Kovan)`, () => {
  const uri = 'https://ipfs/<SAMPLE_URI>/'
  const infuraOptimismUrl = 'https://optimism-kovan.infura.io/v3/'

  let receipt: ContractReceipt,
    KwentaNFT: KwentaNFT,
    deployedCtc,
    provider = new ethers.providers.JsonRpcProvider(
      infuraOptimismUrl + process.env.INFURA_API_KEY
    ),
    owner: Wallet,
    l2Wallets: Wallet[] = [],
    _to: string[] = []

  describe(`tests`, () => {
    before(`tests`, async () => {
      // Create list of test recipients
      const privKeys: string[] = recipientPrivateKeys.keys

      for (let i = 0; i < 206; i++) {
        const privKey = privKeys[i]
        const l2Wallet = new ethers.Wallet(privKey, provider)

        l2Wallets.push(l2Wallet)
      }

      l2Wallets.forEach((l2Wallet: Wallet) => {
        _to.push(l2Wallet.address)
      })

      // Create owner account
      const ownerPrivKey = process.env.PRIVATE_KEY as string

      owner = new ethers.Wallet(ownerPrivKey, provider)

      const Factory__KwentaNFT = await ethers.getContractFactory('KwentaNFT')

      KwentaNFT = await Factory__KwentaNFT.connect(owner).deploy(uri)
      await KwentaNFT.deployed()

      console.log(`\n KwentaNFT contract address: ${KwentaNFT.address} \n`)
    })

    /**
     * @dev 5/5 PASS
     */
    describe(`uri(uint256 tokenId)`, () => {
      it(`should get the uri for tier0 tokenIds`, async () => {
        for (let tokenId = 1; tokenId < 101; tokenId++) {
          const uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          expect(uri_).to.eq(uri + '0.json')
        }
      })

      it(`should get the uri for tier1 tokenIds`, async () => {
        for (let tokenId = 101; tokenId < 151; tokenId++) {
          const uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          expect(uri_).to.eq(uri + '1.json')
        }
      })

      it(`should get the uri for tier2 tokenIds`, async () => {
        for (let tokenId = 151; tokenId < 201; tokenId++) {
          const uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          expect(uri_).to.eq(uri + '2.json')
        }
      })

      it(`should get the uri for tier3 tokenIds`, async () => {
        for (let tokenId = 201; tokenId < 207; tokenId++) {
          const uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          expect(uri_).to.eq(uri + '3.json')
        }
      })

      it(`should throw an error for outOfRange tokenIds`, async () => {
        for (let tokenId = 207; tokenId < 210; tokenId++) {
          const uri_ = KwentaNFT.connect(owner).uri(tokenId)
          await expect(uri_).to.be.revertedWith('TokenIdOutOfRange')
        }
      })
    })

    /**
     * @dev 10/10 PASS
     */
    describe(`distribute(address[] _to)`, () => {
      describe(`shoulds`, () => {
        it(`should have flipped 'hasDistributed' to 'true'`, async () => {
          const distributeTx = await KwentaNFT.connect(owner).distribute(_to)
          await distributeTx.wait()
          const hasDistributed_ = await KwentaNFT.hasDistributed()
          expect(hasDistributed_).eq(true)
        })

        it(`should have gave each tier 0 recipient 1 KwentaNFT`, async () => {
          for (let account = 0; account < 100; account++) {
            const balance = await KwentaNFT.balanceOf(_to[account], 0)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 1 recipient 1 tier 1 KwentaNFT`, async () => {
          for (let account = 100; account < 150; account++) {
            const balance = await KwentaNFT.balanceOf(_to[account], 1)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 2 recipient 1 tier 2 KwentaNFT`, async () => {
          for (let account = 150; account < 200; account++) {
            const balance = await KwentaNFT.balanceOf(_to[account], 2)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 3 recipient 1 tier 3 KwentaNFT`, async () => {
          for (let account = 200; account < 205; account++) {
            const balance = await KwentaNFT.balanceOf(_to[account], 3)
            expect(balance.toNumber()).to.eq(1)
          }
        })
      })

      describe(`should nots`, () => {
        it(`should not have gave each tier 0 recipient any tier 1, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 0; account < 100; account++) {
            const balance1 = await KwentaNFT.balanceOf(_to[account], 1)
            const balance2 = await KwentaNFT.balanceOf(_to[account], 2)
            const balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 1 recipient any tier 0, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 100; account < 150; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[account], 0)
            const balance2 = await KwentaNFT.balanceOf(_to[account], 2)
            const balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 2 recipient any tier 0, 1, nor 3 KwentaNFTs`, async () => {
          for (let account = 150; account < 200; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[account], 0)
            const balance1 = await KwentaNFT.balanceOf(_to[account], 1)
            const balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 3 recipient any tier 0, 1, nor 2 KwentaNFTs`, async () => {
          for (let account = 200; account < 205; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[account], 0)
            const balance1 = await KwentaNFT.balanceOf(_to[account], 1)
            const balance2 = await KwentaNFT.balanceOf(_to[account], 2)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
          }
        })
      })
    })

    /**
     * @dev The revert test throws a weird error but otherwise exhibits
     *      expected behavior
     */
    describe(`disableMint()`, () => {
      // This throws a dumb error
      it(`should revert if not owner`, async () => {
        for (let i = 100; i < 105; i++) {
          const signer = await ethers.getSigner(_to[i])
          const disableMintTx = KwentaNFT.connect(signer).disableMint()

          await expect(disableMintTx).to.be.revertedWith(
            'ProviderError: execution reverted'
          )
        }

        const isMintDisabled = await KwentaNFT.connect(owner).isMintDisabled()
        expect(isMintDisabled).to.eq(false)
      })

      it(`should have minting enabled after failed attempts to disable mint`, async () => {
        const isMintDisabled = await KwentaNFT.connect(owner).isMintDisabled()
        expect(isMintDisabled).to.eq(false)
      })

      it(`should disable minting `, async () => {
        const disableMintTx = await KwentaNFT.connect(owner).disableMint()
        await disableMintTx.wait()
        const isMintDisabled = await KwentaNFT.connect(owner).isMintDisabled()
        expect(isMintDisabled).to.eq(true)
      })
    })
  })
})