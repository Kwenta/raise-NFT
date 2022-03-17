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


describe(`KwentaNFT (on Optimism)`, () => {
  const uri = ''
  const infuraRinkebyUrl = 'https://rinkeby.infura.io/v3/'

  let receipt: ContractReceipt,
    mintTx0: ContractTransaction,
    KwentaNFT: KwentaNFT,
    deployedCtc,
    provider = new ethers.providers.JsonRpcProvider(
      infuraRinkebyUrl + process.env.INFURA_API_KEY
    ),
    owner: Wallet,
    l2Wallets: Wallet[]

  describe(`distribute()`, () => {
    before(`distribute()`, async () => {
      // Create list of test recipients
      const privKeys: string[] = recipientPrivateKeys.keys

      for (let i = 0; i < 206; i++) {
        const privKey = privKeys[i]
        const l2Wallet = new ethers.Wallet(privKey, provider)

        l2Wallets.push(l2Wallet)
      }


      l2Wallets.forEach((l2Wallet: Wallet) => {
        console.log('L2Wallet addresss: ', l2Wallet.address)
      })

      // Create owner account
      /**
       * @todo ADD YOUR PRIVATE KEY TO TEST WITH
       */
      const ownerPrivKey = process.env.PRIVATE_KEY as string

      owner = new ethers.Wallet(ownerPrivKey, provider)

      const Factory__KwentaNFT = await ethers.getContractFactory('KwentaNFT')

      KwentaNFT = await Factory__KwentaNFT.connect(owner).deploy(uri) as KwentaNFT
      KwentaNFT.deployed()

      console.log('\n KwentaNFT contract address: \n', KwentaNFT.address)
      // receipt = await mintTx0.wait()

      deployedCtc = await KwentaNFT.deployTransaction.wait()
      console.log(`\n Gas used to deploy: ${deployedCtc.gasUsed.toString()} gas\m`)
    })

    it(`should have distributed`, async () => {
      let accounts_: any = [],
        distributeTx

      for (let i = 0; i < l2Wallets.length; i++) {
        const account = await l2Wallets[i].getAddress()
        accounts_.push(account)
      }

      const _to = accounts_.slice(0, 208)

      distributeTx = await KwentaNFT.connect(owner).distribute(_to)

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