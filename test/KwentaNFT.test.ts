/* External imports */
import { ethers } from 'hardhat'
import { expect } from 'chai'
import { ContractReceipt, ContractTransaction, utils } from 'ethers'
import { Wallet } from '@ethersproject/wallet'
import { Signer } from '@ethersproject/abstract-signer'
import 'dotenv/config'

/* Internal imports */
import { KwentaNFT } from '../typechain/KwentaNFT'


describe(`KwentaNFT (on Optimism)`, () => {
  const uri = 'https://ipfs.fleek.co/ipfs/bafybeibs5jxyh4yxuasxsew4o47xnomeplzwoycgqckpbvkt5dqcmhms3i'
  const infuraRinkebyUrl = 'https://rinkeby.infura.io/v3/'

  let receipt: ContractReceipt,
    provider = new ethers.providers.JsonRpcProvider(
      infuraRinkebyUrl + process.env.INFURA_API_KEY
    )

  describe(`distribute()`, () => {
    let mintTx0: ContractTransaction,
      KwentaNFT: KwentaNFT,
      deployedCtc,
      accounts: Signer[]

    before(`distribute()`, async () => {
      accounts = await ethers.getSigners()

      const Factory__KwentaNFT = await ethers.getContractFactory('KwentaNFT')

      KwentaNFT = await Factory__KwentaNFT.connect(accounts[0]).deploy(uri) as KwentaNFT
      KwentaNFT.deployed()

      console.log('\n KwentaNFT contract address: \n', KwentaNFT.address)
      // receipt = await mintTx0.wait()

      deployedCtc = await KwentaNFT.deployTransaction.wait()
      console.log(`\n Gas used to deploy: ${deployedCtc.gasUsed.toString()} gas\m`)
    })

    it(`should have distributed`, async () => {
      let accounts_: any = [],
        distributeTx

      for (let i = 0; i < accounts.length; i++) {
        const account = await accounts[i].getAddress()
        accounts_.push(account)
      }

      const _to = accounts_.slice(0, 208)

      distributeTx = await KwentaNFT.connect(accounts[0]).distribute(_to)

      const hasDistributed_ = await KwentaNFT.hasDistributed()
      console.log(`\n hasDistributed bool state var: ${hasDistributed_} \n`)

      expect(hasDistributed_).eq(true)
    })

    describe(`getTokenIDByTier(...)`, () => {
      it(`should get tier `, async () => {
      })
    })

    describe(`disableMint(...)`, () => {
      it(`should disable minting `, async () => {
      })
    })
  })
})