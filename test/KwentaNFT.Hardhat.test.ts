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
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers'


describe(`KwentaNFT (hardhat)`, () => {
  const TIER_0 = 0
  const TIER_1 = 1
  const TIER_2 = 2
  const TIER_3 = 3
  const uri = 'https://ipfs/<SAMPLE_URI>/'

  let receipt: ContractReceipt,
    KwentaNFT: KwentaNFT,
    deployedCtc,
    owner: SignerWithAddress,
    accounts: SignerWithAddress[],
    _to: string[][] = [[], [], [], []],
    _tokenIds: number[][] = [[], [], [], []]

  describe(`tests`, () => {
    before(`tests`, async () => {
      // Create list of test recipients
      accounts = await ethers.getSigners()
      owner = accounts[0]

      // Set accounts and tokenIds for Tier 0
      for (let i = 1; i < 101; i++) {
        _tokenIds[TIER_0].push(i)
        _to[TIER_0].push(accounts[i].address)
      }

      // Set accounts and tokenIds for Tier 1
      for (let i = 101; i < 151; i++) {
        _tokenIds[TIER_1].push(i)
        _to[TIER_1].push(accounts[i].address)
      }

      // Set accounts and tokenIds for Tier 2
      for (let i = 151; i < 201; i++) {
        _tokenIds[TIER_2].push(i)
        _to[TIER_2].push(accounts[i].address)
      }

      // Set accounts and tokenIds for Tier 3
      for (let i = 201; i < 206; i++) {
        _tokenIds[TIER_3].push(i)
        _to[TIER_3].push(accounts[i].address)
      }

      const Factory__KwentaNFT = await ethers.getContractFactory('KwentaNFT')

      KwentaNFT = await Factory__KwentaNFT.connect(owner).deploy(uri)
      await KwentaNFT.deployed()

      console.log(`\n KwentaNFT contract address: ${KwentaNFT.address} \n`)
    })

    /**
     * @dev 10/10 PASS
     */
    describe(`distribute(address[] _to)`, () => {
      describe(`shoulds`, () => {
        it(`should revert if invalid tier`, async () => {
          const invalidTierTx = KwentaNFT.connect(owner).distribute(
            _to[TIER_0],
            _tokenIds[TIER_0],
            4
          )
          await expect(invalidTierTx).to.be.revertedWith('InvalidTier')
        })

        it(`should have distributed to tier 0 `, async () => {
          const distributeTier0Tx = await KwentaNFT.connect(owner).distribute(
            _to[TIER_0],
            _tokenIds[TIER_0],
            TIER_0
          )
          const receipt = await distributeTier0Tx.wait()

          console.log(
            'Gas consumed for distribute to tier 0: ',
            receipt.gasUsed.toString()
          )

          const hdt0_ = await KwentaNFT.hdt0()
          expect(hdt0_).eq(true)
        })

        it(`should have distributed to tier 1`, async () => {
          const distributeTier1Tx = await KwentaNFT.connect(owner).distribute(
            _to[TIER_1],
            _tokenIds[TIER_1],
            TIER_1
          )
          const receipt = await distributeTier1Tx.wait()

          console.log(
            'Gas consumed for distribute to tier 1: ',
            receipt.gasUsed.toString()
          )

          const hdt1_ = await KwentaNFT.hdt1()
          expect(hdt1_).eq(true)
        })

        it(`should have distributed to tier 2`, async () => {
          const distributeTier2Tx = await KwentaNFT.connect(owner).distribute(
            _to[TIER_2],
            _tokenIds[TIER_2],
            TIER_2
          )
          const receipt = await distributeTier2Tx.wait()

          console.log(
            'Gas consumed for distribute to tier 2: ',
            receipt.gasUsed.toString()
          )

          const hdt2_ = await KwentaNFT.hdt2()
          expect(hdt2_).eq(true)
        })

        it(`should have distributed to tier 3`, async () => {
          const distributeTier3Tx = await KwentaNFT.connect(owner).distribute(
            _to[TIER_3],
            _tokenIds[TIER_3],
            TIER_3
          )
          const receipt = await distributeTier3Tx.wait()

          console.log(
            'Gas consumed for distribute to tier 3: ',
            receipt.gasUsed.toString()
          )

          const hdt3_ = await KwentaNFT.hdt3()
          expect(hdt3_).eq(true)
        })

        it(`should have gave each tier 0 recipient 1 KwentaNFT`, async () => {
          for (let account = 0; account < 100; account++) {
            const balance = await KwentaNFT.balanceOf(_to[TIER_0][account], TIER_0)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 1 recipient 1 tier 1 KwentaNFT`, async () => {
          for (let account = 0; account < 49; account++) {
            const balance = await KwentaNFT.balanceOf(_to[TIER_1][account], TIER_1)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 2 recipient 1 tier 2 KwentaNFT`, async () => {
          for (let account = 0; account < 49; account++) {
            const balance = await KwentaNFT.balanceOf(_to[TIER_2][account], TIER_2)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 3 recipient 1 tier 3 KwentaNFT`, async () => {
          for (let account = 0; account < 5; account++) {
            const balance = await KwentaNFT.balanceOf(_to[TIER_3][account], TIER_3)
            expect(balance.toNumber()).to.eq(1)
          }
        })
      })

      describe(`should nots`, () => {
        it(`should not be able to mint again`, async () => {
          const failedMint = KwentaNFT.connect(owner).distribute(
            _to[TIER_0],
            _tokenIds[TIER_0],
            TIER_0
          )
          await expect(failedMint).to.be.revertedWith('HasDistributed')
        })

        it(`should not have gave each tier 0 recipient any tier 1, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 0; account < 100; account++) {
            const balance1 = await KwentaNFT.balanceOf(_to[TIER_0][account], 1)
            const balance2 = await KwentaNFT.balanceOf(_to[TIER_0][account], 2)
            const balance3 = await KwentaNFT.balanceOf(_to[TIER_0][account], 3)

            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 1 recipient any tier 0, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 0; account < 49; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[TIER_1][account], 0)
            const balance2 = await KwentaNFT.balanceOf(_to[TIER_1][account], 2)
            const balance3 = await KwentaNFT.balanceOf(_to[TIER_1][account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 2 recipient any tier 0, 1, nor 3 KwentaNFTs`, async () => {
          for (let account = 0; account < 49; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[TIER_2][account], 0)
            const balance1 = await KwentaNFT.balanceOf(_to[TIER_2][account], 1)
            const balance3 = await KwentaNFT.balanceOf(_to[TIER_2][account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should not have gave each tier 3 recipient any tier 0, 1, nor 2 KwentaNFTs`, async () => {
          for (let account = 0; account < 5; account++) {
            const balance0 = await KwentaNFT.balanceOf(_to[TIER_3][account], 0)
            const balance1 = await KwentaNFT.balanceOf(_to[TIER_3][account], 1)
            const balance2 = await KwentaNFT.balanceOf(_to[TIER_3][account], 2)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
          }
        })
      })
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
        for (let tokenId = 201; tokenId < 206; tokenId++) {
          const uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          expect(uri_).to.eq(uri + '3.json')
        }
      })
    })

    /**
     * @dev 3/3 PASS
     */
    describe(`disableMint()`, () => {
      // This throws a dumb error
      it(`should revert if not owner`, async () => {
        for (let i = 0; i < 5; i++) {
          const signer = await ethers.getSigner(_to[TIER_0][i])
          const disableMintTx = KwentaNFT.connect(signer).disableMint()
          await expect(disableMintTx).to.be.revertedWith('CallerIsNotOwner')
        }
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