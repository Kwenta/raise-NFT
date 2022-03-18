/* External imports */
import { ethers } from 'hardhat'
import { expect } from 'chai'
import { ContractReceipt, ContractTransaction, utils } from 'ethers'
import { Wallet } from '@ethersproject/wallet'
import { Signer } from '@ethersproject/abstract-signer'
import { JsonRpcProvider } from '@ethersproject/providers'
import 'dotenv/config'

/* Internal imports */
import { KwentaNFT } from '../typechain/KwentaNFT'
import recipientPrivateKeys from '../recipientPrivateKeys.json'


describe(`KwentaNFT (Optimism Kovan)`, () => {
  const uri = 'https://ipfs/<SAMPLE_URI>/'
  const infuraRinkebyUrl = 'https://optimism-kovan.infura.io/v3/'

  let receipt: ContractReceipt,
    KwentaNFT: KwentaNFT,
    deployedCtc,
    provider = new ethers.providers.JsonRpcProvider(
      infuraRinkebyUrl + process.env.INFURA_API_KEY
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
      KwentaNFT.deployed()

      console.log(`\n KwentaNFT contract address: ${KwentaNFT.address} \n`)

      deployedCtc = await KwentaNFT.deployTransaction.wait()

      console.log(`Gas used to deploy: ${deployedCtc.gasUsed.toString()} gas \n`)
    })

    describe(`uri(uint256 tokenId)`, () => {
      // it(`should get the uri for tier0 tokenIds`, async () => {
      //   for (let tokenId = 1; tokenId < 101; tokenId++) {
      //     let uri_ = await KwentaNFT.connect(owner).uri(tokenId)
      //     if (tokenId < 101) expect(uri_).to.eq(uri + '0.json')
      //   }
      // })

      // it(`should get the uri for tier1 tokenIds`, async () => {
      //   for (let tokenId = 101; tokenId < 151; tokenId++) {
      //     let uri_ = await KwentaNFT.connect(owner).uri(tokenId)
      //     if (tokenId > 100 && tokenId < 151) expect(uri_).to.eq(uri + '1.json')
      //   }
      // })

      // it(`should get the uri for tier2 tokenIds`, async () => {
      //   for (let tokenId = 151; tokenId < 201; tokenId++) {
      //     let uri_ = await KwentaNFT.connect(owner).uri(tokenId)
      //     if (tokenId > 150 && tokenId < 201) expect(uri_).to.eq(uri + '2.json')
      //   }
      // })

      it(`should get the uri for tier3 tokenIds`, async () => {
        for (let tokenId = 201; tokenId < 207; tokenId++) {
          let uri_ = await KwentaNFT.connect(owner).uri(tokenId)
          if (tokenId > 200 && tokenId < 207) expect(uri_).to.eq(uri + '3.json')
        }
      })

      // it(`should get the uri for outOfRange tokenIds`, async () => {
      //   let uri_

      //   for (let tokenId = 206; tokenId < 210; tokenId++) {
      //     uri_ = await KwentaNFT.connect(owner).uri(tokenId)

      //     if (tokenId > 206) console.log('Should return outOfRange error: ', uri_)
      //   }
      // })
    })

    describe(`distribute(address[] _to)`, () => {
      describe(`shoulds`, () => {
        it(`should have flipped 'hasDistributed' to 'true'`, async () => {
          const distributeTx = await KwentaNFT.connect(owner).distribute(_to)
          await distributeTx.wait()

          const hasDistributed_ = await KwentaNFT.hasDistributed()
          console.log(`\n hasDistributed bool state var: ${hasDistributed_} \n`)

          expect(hasDistributed_).eq(true)
        })

        it(`should have gave each tier 0 recipient 1 KwentaNFT`, async () => {
          for (let account = 0; account < 100; account++) {
            let balance = await KwentaNFT.balanceOf(_to[account], 0)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 0 recipient 1 tier 0 KwentaNFT`, async () => {
          for (let account = 0; account < 100; account++) {
            let balance = await KwentaNFT.balanceOf(_to[account], 0)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 1 recipient 1 tier 1 KwentaNFT`, async () => {
          for (let account = 100; account < 150; account++) {
            let balance = await KwentaNFT.balanceOf(_to[account], 1)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 2 recipient 1 tier 2 KwentaNFT`, async () => {
          for (let account = 150; account < 200; account++) {
            let balance = await KwentaNFT.balanceOf(_to[account], 2)
            expect(balance.toNumber()).to.eq(1)
          }
        })

        it(`should have gave each tier 3 recipient 1 tier 3 KwentaNFT`, async () => {
          for (let account = 200; account < 206; account++) {
            let balance = await KwentaNFT.balanceOf(_to[account], 3)
            expect(balance.toNumber()).to.eq(1)
          }
        })
      })

      describe(`should nots`, () => {
        it(`should not have gave each tier 0 recipient any tier 1, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 0; account < 100; account++) {
            let balance1 = await KwentaNFT.balanceOf(_to[account], 1),
              balance2 = await KwentaNFT.balanceOf(_to[account], 2),
              balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should have gave each tier 1 recipient any tier 0, 2, nor 3 KwentaNFTs`, async () => {
          for (let account = 100; account < 150; account++) {
            let balance0 = await KwentaNFT.balanceOf(_to[account], 0),
              balance2 = await KwentaNFT.balanceOf(_to[account], 2),
              balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should have gave each tier 2 recipient any tier 0, 1, nor 3 KwentaNFTs`, async () => {
          for (let account = 150; account < 200; account++) {
            let balance0 = await KwentaNFT.balanceOf(_to[account], 0),
              balance1 = await KwentaNFT.balanceOf(_to[account], 1),
              balance3 = await KwentaNFT.balanceOf(_to[account], 3)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance3.toNumber()).to.eq(0)
          }
        })

        it(`should have gave each tier 3 recipient any tier 0, 1, nor 2 KwentaNFTs`, async () => {
          for (let account = 200; account < 206; account++) {
            let balance0 = await KwentaNFT.balanceOf(_to[account], 0),
              balance1 = await KwentaNFT.balanceOf(_to[account], 1),
              balance2 = await KwentaNFT.balanceOf(_to[account], 2)

            expect(balance0.toNumber()).to.eq(0)
            expect(balance1.toNumber()).to.eq(0)
            expect(balance2.toNumber()).to.eq(0)
          }
        })
      })
    })

    describe(`disableMint()`, () => {
      it(`should revert if not owner `, async () => {
        const disableMintTx = await KwentaNFT.connect(
          _to[_to.length - 1]
        ).disableMint()
        const isMintDisabled = await KwentaNFT.connect(owner).isMintDisabled()
        expect(isMintDisabled).to.eq(true)
      })

      it(`should disable minting `, async () => {
        const disableMintTx = await KwentaNFT.connect(owner).disableMint()
        const disableMintTxReceipt = await disableMintTx.wait()
        const isMintDisabled = await KwentaNFT.connect(owner).isMintDisabled()
        expect(isMintDisabled).to.eq(true)
      })
    })
  })
})