import { ethers } from 'hardhat';
import { Contract, Signer } from 'ethers';
import { expect } from 'chai';

describe('cardNft', function () {
  let cardNft: Contract;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const CardNft = await ethers.getContractFactory('cardNft');
    cardNft = await CardNft.deploy();
    await cardNft.deployed();
  });

  it('Should deploy contract', async function () {
    expect(cardNft.address).to.not.equal(0);
  });

  it('Should mint personal card', async function () {
    const cardCost = await cardNft.getCardCost();
    const overrides = { value: cardCost };
    const name = 'testName';
    const group = 'testGroup';
    const job = 'testJob';
    const phone = '010-1234-5678';

    await cardNft.connect(addr1).issueCard(name, group, job, phone, overrides);
    const tokenId = await cardNft.tokenOfOwnerByIndex(await addr1.getAddress(), 0);

    const card = await cardNft.userData(tokenId);

    expect(card.name).to.equal(name);
    expect(card.group).to.equal(group);
    expect(card.job).to.equal(job);
    expect(card.phone).to.equal(phone);
    expect(card.owner).to.equal(await addr1.getAddress());
  });

  it('Should deposit organization', async function () {
    const deposit = 2 * 10 ** 18;
    const orgName = 'testOrgName';
    const overrides = { value: deposit };

    await cardNft.connect(addr1).deposit(orgName, overrides);

    expect(await cardNft.members(await addr1.getAddress())).to.equal(true);
    expect(await cardNft.orgName(await addr1.getAddress())).to.equal(orgName);
  });
})