

const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('Game');
    const gameContract = await gameContractFactory.deploy(
    ["Mozart", "Jacob_Fuger", "Larry_Ellison"],       // Names
    ["https://i.imgur.com/pKd5Sdk.png", // Images
    "https://i.imgur.com/xVu4vFL.png", 
    "https://i.imgur.com/WMB6g9u.png"],
    [100, 200, 300],                    // HP values
    [100, 50, 25], //Attack
    [10,20,30]  //regen
    , "Bad-Taste",
    "https://i.imgur.com/FgQMl2N.png",
    10000,
    50
    );
    await gameContract.deployed();

    console.log("Contract deployed to:", gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    let returnedTokenURI = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenURI);

    attack = await gameContract.attackBoss();
    await attack.wait();

    attack = await gameContract.attackBoss();
    await attack.wait();

};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } 
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();