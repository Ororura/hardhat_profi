const {ethers} = require("hardhat");
const {expect} = require("chai");

describe("Contract", function () {
    let owner;
    let account2;
    let account3;
    let contract;

    async function beforeEach() {
        [owner, account2, account3] = await ethers.getSigners();
        const contractFactory = await ethers.getContractFactory('Owner', owner);
        contract = await contractFactory.deploy({from: owner});
    }

    it("Registration", async function () {
        await beforeEach();
        await contract.createUser("test");
        await expect(contract.connect(account2).createUser("test")).to.be.revertedWith("Пользователь с таким логином уже существует");
    })

    it("UpdateWhiteList", async function () {
        await beforeEach();
        await contract.updateWhiteList(account2.getAddress())
        await expect(contract.updateWhiteList(account2.getAddress())).to.be.revertedWith("Пользователь уже в вайтлисте")
    })

    it("SellProduct", async function () {
        await beforeEach();
        await expect(contract.connect(account2).createProduct("Product", 120, "info")).to.be.revertedWith("Вы не в вайтлисте")
        await contract.updateWhiteList(account2.getAddress());
        await contract.connect(account2).createProduct("Product", "120", "Info");
        await contract.approveProduct(0);
        await expect(contract.connect(account2).approveProduct(0)).to.be.revertedWith("Неверный статус продукта");
        await contract.connect(account3).buyProduct(0, {value: 120});
        await expect(contract.connect(account3).buyProduct(0, {value: 1})).to.be.revertedWith("Неверный статус продукта");
        await contract.connect(account3).sellProduct(0)
        await expect(contract.sellProduct(0)).to.be.revertedWith("Неверный статус продукта");
    })

})
